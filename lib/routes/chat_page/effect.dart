import 'dart:convert' as convert;

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/image_utils.dart';
import 'package:flutter_server_client/utils/native_util_plugin.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';
import 'package:flutter_server_client/utils/toast.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import '../../app.dart';
import 'action.dart';
import 'state.dart';

Effect<ChatState> buildEffect() {
  return combineEffects(<Object, Effect<ChatState>>{
    Lifecycle.initState: _initState,
    Lifecycle.dispose: _dispose,
    Lifecycle.build: _build,
    ChatAction.loadMoreMsg: _loadMoreMsg
  });
}

Future _build(Action action, Context<ChatState> ctx) async {
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-16
/// *@Description: 加载历史消息
Future _loadMoreMsg(Action action, Context<ChatState> ctx) async {
  checkNetworkAvailable().then((isConnected) async {
    if (isConnected) {
      dynamic messages = await flutterNimPlugin.fetchMessageHistory(
          sessionId: ctx.state.sessionId);
      List<MessageEntity> historyMessages = ctx.state.messageList;
      for (int i = 0; i < messages.length; i++) {
        historyMessages.insert(0, MessageEntity.fromJson(messages[i]));
      }
      ctx.dispatch(ChatActionCreator.updateMessageList(historyMessages));
    } else {
      Toast.show('请检查网络');
    }
  });
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 数据初始化
void _initState(Action action, Context<ChatState> ctx) async {
  rootBundle.loadString('assets/data/emoji_code.json').then((value) {
    ctx.dispatch(ChatActionCreator.initJsonCodeMap(convert.jsonDecode(value)));
  });
  rootBundle.loadString('assets/data/emoji_decode.json').then((value) {
    ctx.dispatch(
        ChatActionCreator.initJsonDecodeMap(convert.jsonDecode(value)));
  });
  //绑定软盘弹出事件
  KeyboardVisibilityNotification().addNewListener(
    onChange: (bool visible) async {
      if (visible) {
        ctx.dispatch(ChatActionCreator.resetShow());
        try {
          await Future.delayed(Duration(milliseconds: 200));
          ctx.state.scrollController.position
              .jumpTo(ctx.state.scrollController.position.maxScrollExtent);
        } catch (e) {}
      }
    },
  );
  //接受消息监听
  flutterNimPlugin.addReceiveMessageListener((MessageEntity message) async {
    List<MessageEntity> messageList = ctx.state.messageList;
    if (message.session.sessionId == ctx.state.sessionId) {
      messageList.add(message);
      ctx.dispatch(ChatActionCreator.updateMessageList(messageList));
      await Future.delayed(Duration(milliseconds: 500));
      ctx.state.scrollController
          .jumpTo(ctx.state.scrollController.position.maxScrollExtent);
    }
  });
  ctx.state.scrollController.addListener(() {
    if (ctx.state.scrollController.position.pixels ==
        ctx.state.scrollController.position.maxScrollExtent) {}
  });

  if (ctx.state.guideFaceList.length > 0) {
    ctx.dispatch(ChatActionCreator.updateGuideFaceList([]));
  }
  List<Widget> guideFaceList = new List();
  //添加表情图
  List<String> _faceList = new List();
  String faceDeletePath = ImageUtils.getImgPath('face_delete', dir: 'face');
  String facePath;
  for (int i = 1; i < 70; i++) {
    facePath = ImageUtils.getImgPath('emoji_${i.toString()}',
        dir: 'face', format: 'gif');
    _faceList.add(facePath);
    if (i == 23 || i == 46 || i == 69) {
      _faceList.add(faceDeletePath);
      guideFaceList.add(_gridView(8, _faceList, ctx));
      _faceList.clear();
    }
  }
  ctx.dispatch(ChatActionCreator.updateGuideFaceList(guideFaceList));
  checkNetworkAvailable().then((isConnected) async {
    if (isConnected) {
      dynamic messages = await flutterNimPlugin.fetchMessageHistory(
          sessionId: ctx.state.sessionId);
      List<MessageEntity> historyMessages = ctx.state.messageList;
      for (int i = 0; i < messages.length; i++) {
        historyMessages.insert(0, MessageEntity.fromJson(messages[i]));
      }
      ctx.dispatch(ChatActionCreator.updateMessageList(historyMessages));
      await Future.delayed(Duration(milliseconds: 500));
      ctx.state.scrollController
          .jumpTo(ctx.state.scrollController.position.maxScrollExtent);
    } else {
      Toast.show('请检查网络');
    }
  });
}

void _dispose(Action action, Context<ChatState> ctx) {
  if (ctx.state.timer != null) {
    ctx.state.timer.cancel();
    ctx.dispatch(ChatActionCreator.initTimer(null));
  }
  eventBus.fire(Constant.refreshSessions);
  flutterNimPlugin.resetMessage();
  //设置会话消息已读
  flutterNimPlugin.markAllMessagesReadInSession(ctx.state.sessionId);
  flutterNimPlugin.removeReceiveMessageListener();
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: emoji看板滑动
_gridView(int crossAxisCount, List<String> list, Context<ChatState> ctx) {
  return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: EdgeInsets.all(0.0),
      children: list.map((String name) {
        return Material(
          child: IconButton(
              onPressed: () {
                String msgTextTmp = ctx.state.controller.text;

                if (name.contains('face_delete')) {
                  if (msgTextTmp[msgTextTmp.length - 1] == ']') {
                    msgTextTmp =
                        msgTextTmp.substring(0, msgTextTmp.lastIndexOf('['));
                  } else if (msgTextTmp.isNotEmpty) {
                    msgTextTmp = msgTextTmp.substring(0, msgTextTmp.length - 1);
                  }
                } else {
                  msgTextTmp = msgTextTmp +
                      ctx.state.jsonCodeMap[
                          '${name.substring(name.lastIndexOf('/') + 1, name.length)}'];
                  //表情因为取的是assets里的图，所以当初文本发送
//                _buildTextMessage(name);
                }
                ctx.state.controller.text = msgTextTmp;
                if (msgTextTmp.isEmpty) {
                  ctx.dispatch(ChatActionCreator.updateSendState(false));
                } else {
                  ctx.dispatch(ChatActionCreator.updateSendState(true));
                }
              },
              icon: Image.asset(name, width: 32, height: 32)),
        );
      }).toList());
}
