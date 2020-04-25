import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_server_client/constants/constants.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/native_util_plugin.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/nim_user_info.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/recent_session_entity.dart';
import 'package:flutter_server_client/utils/routes/fluro_navigator.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:flutter_server_client/utils/toast.dart';
import '../../app.dart';
import 'action.dart';
import 'state.dart';

Effect<SessionState> buildEffect() {
  return combineEffects(<Object, Effect<SessionState>>{
    Lifecycle.initState: _initState,
    Lifecycle.build: _build,
    Lifecycle.dispose: _dispose,
    Lifecycle.didChangeAppLifecycleState: _didChangeAppLifecycleState,
    SessionAction.onRefresh: _onRefresh,
    SessionAction.onLoadMore: _onLoadMore,
  });
}

void _didChangeAppLifecycleState(Action action, Context<SessionState> ctx) {
  switch (action.payload) {
    case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
      break;
    case AppLifecycleState.resumed: // 应用程序可见，前台
      break;
    case AppLifecycleState.paused: // 应用程序不可见，后台
      break;
  }
}

void _build(Action action, Context<SessionState> ctx) {
}

void _dispose(Action action, Context<SessionState> ctx) {
  flutterNimPlugin.removeSessionUpdateListener();
  flutterNimPlugin.removeKickListener();
}

void _initState(Action action, Context<SessionState> ctx) {
  eventBus.on().listen((data) {
    if (data == Constant.refreshSessions) {
      _onRefresh(action, ctx);
    }
  });
  //掉线监听
  flutterNimPlugin.addKickListener(() async {
    Toast.show('你已被挤下线');
    await SpUtil.putObject(Constant.accountInfo, null);
    flutterNimPlugin.loginOut();
    NavigatorUtils.push(ctx.context, Routes.loginPage,
        replace: true, clearStack: true);
  });
  //iOS检测到屏幕锁定和解锁后重新登录激活
  if (Platform.isIOS) {
    addScreenLockListener(() {
      autoLogin();
    });
  }
  _onRefresh(action, ctx);
}

void autoLogin() {
  SpUtil.getObj(Constant.accountInfo, (objc) {
    if (objc != null) {
      checkNetworkAvailable().then((isConnected) {
        if (isConnected) {
          //网易云信账号登录
          flutterNimPlugin
              .nimLogin(
                  account: objc['account'],
                  token: objc['pwd'],
                  appKey: Constants.APP_KEY)
              .then((res) async {})
              .catchError((err) {
          });
        } else {
          Toast.show('请检查网络');
        }
      });
    }
  });
}

void _onRefresh(Action action, Context<SessionState> ctx) {
  List<String> userIds = List();
  flutterNimPlugin.getAllSessions().then((dynamic recentSessionList) {
    List<RecentSessionEntity> sessions = List();
    for (int i = 0; i < recentSessionList.length; i++) {
      sessions.add(RecentSessionEntity.fromJson(recentSessionList[i]));
    }
    int endIndex = ctx.state.pageSize < sessions.length
        ? ctx.state.pageSize
        : sessions.length;
    for (int i = 0; i < endIndex; i++) {
      userIds.add(
          RecentSessionEntity.fromJson(recentSessionList[i]).session.sessionId);
    }
    flutterNimPlugin.getUsersInfo(userIds).then((dynamic usersInfoData) {
      List<NIMUserEntity> usersInfo = List();
      for (int i = 0; i < usersInfoData.length; i++) {
        usersInfo.add(NIMUserEntity.fromJson(usersInfoData[i]));
      }
      ctx.dispatch(
          SessionActionCreator.updateIndex(ctx.state.index + userIds.length));
      ctx.dispatch(SessionActionCreator.refresh(sessions, usersInfo));
      ctx.state.controller.finishRefresh(success: true);
      //会话监听
      if(flutterNimPlugin.eventHanders.sessionUpdateMessage.length==0){
        flutterNimPlugin.addSessionUpdateListener(() {
          _onRefresh(action, ctx);
        });
      }
    });
  });
}

void _onLoadMore(Action action, Context<SessionState> ctx) {
  List<String> userIds = List();
  int endIndex =
      ctx.state.pageSize < ctx.state.sessions.length - ctx.state.index
          ? ctx.state.pageSize
          : ctx.state.sessions.length - ctx.state.index;

  for (int i = ctx.state.index; i < ctx.state.index + endIndex; i++) {
    userIds.add(ctx.state.sessions[i].session.sessionId);
  }
  flutterNimPlugin.getUsersInfo(userIds).then((dynamic usersInfoData) {
    List<NIMUserEntity> usersInfo = List();
    List<NIMUserEntity> usersInfoTmp = ctx.state.usersInfo;
    for (int i = 0; i < usersInfoData.length; i++) {
      usersInfo.add(NIMUserEntity.fromJson(usersInfoData[i]));
    }
    usersInfoTmp.addAll(usersInfo);

    ctx.dispatch(
        SessionActionCreator.refresh(ctx.state.sessions, usersInfoTmp));
    ctx.dispatch(SessionActionCreator.updateIndex(usersInfoTmp.length));
    ctx.state.controller
        .finishLoad(success: true, noMore: usersInfoTmp.length == 0);
  }).catchError((onError) {
    ctx.state.controller.finishLoad(success: false, noMore: false);
  });
}
