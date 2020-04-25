import 'package:fish_redux/fish_redux.dart';
import 'package:flustars/flustars.dart' hide ScreenUtil;
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/data_tool.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/nim_user_info.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/recent_session_entity.dart';
import 'package:flutter_server_client/utils/routes/fluro_navigator.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:flutter_server_client/utils/screen_util.dart';
import 'package:flutter_server_client/widgets/load_image.dart';
import 'package:flutter_server_client/widgets/opacity_button.dart';

import '../../app.dart';
import 'action.dart';
import 'state.dart';

Widget buildView(
    SessionState state, Dispatch dispatch, ViewService viewService) {
  return Material(
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                  width: ScreenUtil.screenWidthDp,
                  height: scaleSize(44),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OpacityButton(
                            onTap: () {
                              flutterNimPlugin.markAllMessagesRead();
                              dispatch(SessionActionCreator.onRefresh());
                            },
                            child: Container(
                              width: scaleSize(90),
                              height: scaleSize(44),
                              margin: EdgeInsets.only(left: scaleSize(20)),
                              child: Center(
                                child: Text('全部标记已读'),
                              ),
                            ),
                          ),
                          Text(
                            '消息',
                            style: TextStyle(
                                fontSize: setSp(18), color: Color(0xff2b3642)),
                          ),
                          OpacityButton(
                            onTap: () async {
                              await SpUtil.putObject(
                                  Constant.accountInfo, null);
                              flutterNimPlugin.loginOut();
                              NavigatorUtils.push(
                                  viewService.context, Routes.loginPage,
                                  replace: true, clearStack: true);
                            },
                            child: Container(
                              width: scaleSize(80),
                              height: scaleSize(44),
                              margin: EdgeInsets.only(right: scaleSize(20)),
                              child: Center(
                                child: Text('退出登录'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
              Container(
                width: ScreenUtil.screenWidthDp,
                height: 2,
                color: MyColors.pageDefaultBackgroundColor,
              ),
              Container(
                margin:
                    EdgeInsets.only(left: scaleSize(20), right: scaleSize(20)),
                child: TextField(
                  keyboardAppearance: Brightness.light,
                  maxLength: 10,
                  cursorColor: MyColors.themeColor,
                  style:
                      TextStyle(color: Color(0xff072b2b), fontSize: setSp(16)),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '搜索${state.usersInfo.length}个会话',
                    hintStyle: TextStyle(
                        color: Color(0xff999999), fontSize: setSp(16)),
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (String value) {
                    List<RecentSessionEntity> sessions = List();
                    List<NIMUserEntity> usersInfo = List();
                    for (int i = 0; i < state.usersInfoTmp.length; i++) {
                      if (state.usersInfoTmp[i].userInfo.nickName
                          .contains(value)) {
                        sessions.add(state.sessionsTmp[i]);
                        usersInfo.add(state.usersInfoTmp[i]);
                      }
                    }
                    dispatch(SessionActionCreator.filterRefresh(
                        sessions, usersInfo));
                  },
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: EasyRefresh.custom(
                    enableControlFinishRefresh: true,
                    enableControlFinishLoad: true,
                    taskIndependence: false,
                    controller: state.controller,
                    scrollDirection: Axis.vertical,
                    topBouncing: true,
                    bottomBouncing: true,
                    header: ClassicalHeader(
                        refreshedText: '刷新完成',
                        refreshText: '下拉以刷新',
                        refreshFailedText: '刷新失败',
                        refreshingText: '正在刷新...',
                        refreshReadyText: '释放以刷新'),
                    footer: ClassicalFooter(
                        loadedText: '没有更多数据了',
                        loadFailedText: '加载失败',
                        loadingText: '正在加载...',
                        loadReadyText: '加载完成',
                        loadText: '释放以加载'),
                    onRefresh: () async {
                      dispatch(SessionActionCreator.onRefresh());
                    },
                    onLoad: () async {
                      dispatch(SessionActionCreator.onLoadMore());
                    },
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _generateChild(context, index, state);
                          },
                          childCount: state.usersInfo.length,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _generateChild(context, index, SessionState state) {
  RecentSessionEntity session = state.sessions[index];
  NIMUserEntity user = state.usersInfo[index];
  String messageType = '';
  switch (session.lastMessage.messageType) {
    case 'NIMMessageTypeText':
    case 'text':
      messageType =
          session.lastMessage.text != null ? session.lastMessage.text : '';
      break;
    case 'NIMMessageTypeImage':
    case 'image':
      messageType = '[图片消息]';
      break;
    case 'NIMMessageTypeAudio':
    case 'audio':
      messageType = '[语音消息]';
      break;
    case 'NIMMessageTypeCustom':
    case 'custom':
      String type = session.lastMessage.messageObject != null
          ? session.lastMessage.messageObject['type']
          : 'other';
      if (type == 'Question') {
        messageType = '[客服聊天模板]';
      } else if (type == 'JIFEN') {
        messageType = '[积分消息]';
      } else {
        messageType = '';
      }
      break;
    default:
      break;
  }

  return Container(
    key: Key(session.session.sessionId),
    decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                width: 1, color: MyColors.pageDefaultBackgroundColor))),
    width: ScreenUtil.screenWidthDp,
    height: scaleSize(83),
    child: FlatButton(
      onPressed: () {
        //设置会话消息已读
        flutterNimPlugin
            .markAllMessagesReadInSession(session.session.sessionId);
        NavigatorUtils.push(context,
            '${Routes.chatPage}?sessionId=${session.session.sessionId}&nickName=${Uri.encodeComponent(user.userInfo.nickName)}');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              LoadImage(
                user.userInfo.avatarUrl.isNotEmpty
                    ? user.userInfo.avatarUrl
                    : 'https://pic.guigug.com/tou.png',
                width: 44,
                height: 44,
              ),
              Container(
                width: scaleSize(140),
                margin:
                    EdgeInsets.only(top: scaleSize(20), left: scaleSize(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.userInfo.nickName,
                      style: TextStyle(
                        fontSize: setSp(15),
                        color: Color(0xff2b3642),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: scaleSize(5)),
                      child: Text(
                        messageType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: setSp(13), color: Color(0xff9B9B9B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: scaleSize(20)),
                child: Text(
                  '${transTime(session.lastMessage.timestamp)}',
                  style:
                      TextStyle(fontSize: setSp(12), color: Color(0xffb7c6e4)),
                ),
              ),
              session.unreadCount > 0
                  ? Container(
                      margin: EdgeInsets.only(top: scaleSize(10)),
                      width: scaleSize(20),
                      height: scaleSize(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(scaleSize(10)),
                          color: Colors.red),
                      child: Center(
                        child: Text(
                          session.unreadCount > 99
                              ? '99+'
                              : '${session.unreadCount}',
                          style: TextStyle(
                              fontSize:
                                  setSp(session.unreadCount > 99 ? 8 : 12),
                              color: Colors.white),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          )
        ],
      ),
    ),
  );
}
