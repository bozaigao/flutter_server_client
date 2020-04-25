import 'dart:async';
import 'dart:io';
import 'package:fish_redux/fish_redux.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/data_tool.dart';
import 'package:flutter_server_client/utils/image_utils.dart';
import 'package:flutter_server_client/utils/log_utils.dart';
import 'package:flutter_server_client/utils/nim_plugin/flutter_nim_plugin.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';
import 'package:flutter_server_client/utils/routes/fluro_navigator.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:flutter_server_client/utils/screen_util.dart';
import 'package:flutter_server_client/utils/toast.dart';
import 'package:flutter_server_client/widgets/chat_item_widgets.dart';
import 'package:flutter_server_client/widgets/load_image.dart';
import 'package:flutter_server_client/widgets/opacity_button.dart';
import 'package:flutter_server_client/widgets/popupwindow_widget.dart';
import 'package:flutter_server_client/widgets/top_header.dart';
import '../../app.dart';
import 'action.dart';
import 'state.dart';

const bottomWidgetHeight = 170;
int duration = 0;

Widget buildView(ChatState state, Dispatch dispatch, ViewService viewService) {
  return Material(
    child: Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: SafeArea(
              child: _body(viewService.context, dispatch, state),
            ),
          ),
          state.recording
              ? Positioned(
                  left: ScreenUtil.screenWidthDp / 2 - 60,
                  top: ScreenUtil.screenHeightDp / 2 - 60,
                  child: Container(
                    width: scaleSize(120),
                    height: scaleSize(120),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: ImageUtils.getAssetImage('ico_loading_bg'),
                          fit: BoxFit.fill),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: scaleSize(25)),
                      child: Column(
                        children: <Widget>[
                          LoadImage(
                            'mic_play',
                            format: 'gif',
                            width: scaleSize(50),
                            height: scaleSize(50),
                            fit: BoxFit.contain,
                          ),
                          Text(
                            '音频录制中',
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: setSp(14),
                              color: MyColors.textGrayColor,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    ),
  );
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 主框架
_body(BuildContext context, Dispatch dispatch, ChatState state) {
  return Container(
    color: Colors.white,
    child: Column(children: <Widget>[
      TopHeader(title: '@${state.nickName}'),
      Flexible(
          child: Material(
        child: InkWell(
          child: Scrollbar(
            child: _messageListView(context, state, dispatch),
          ),
          onTap: () {
            state.textFieldNode.unfocus();
            dispatch(ChatActionCreator.resetShow());
          },
        ),
      )),
      Divider(height: 1.0),
      Container(
        decoration: new BoxDecoration(
          color: Colors.white,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: scaleSize(44), maxHeight: scaleSize(88)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    left: 8, right: 8, bottom: state.isShowVoice ? 9 : 18),
                child: OpacityButton(
                  child: state.isShowVoice
                      ? LoadImage(
                          'ico_message_keyboard',
                          width: scaleSize(25),
                          height: scaleSize(25),
                          fit: BoxFit.contain,
                        )
                      : LoadImage(
                          'ico_message_mic',
                          width: scaleSize(25),
                          height: scaleSize(25),
                          fit: BoxFit.contain,
                        ),
                  onTap: () {
                    if (state.isShowVoice) {
                      dispatch(ChatActionCreator.updateVoiceState(false));
                    } else {
                      state.textFieldNode.unfocus();
                      dispatch(ChatActionCreator.updateVoiceState(true));
                      dispatch(ChatActionCreator.updateFaceState(false));
                      dispatch(ChatActionCreator.updateToolsState(false));
                    }
                  },
                ),
              ),
              Flexible(child: _enterWidget(context, state, dispatch)),
              Container(
                margin: EdgeInsets.only(
                    left: 8, right: 8, bottom: state.isShowVoice ? 9 : 18),
                child: OpacityButton(
                  child: state.isShowFace
                      ? LoadImage(
                          'ico_message_keyboard',
                          width: scaleSize(25),
                          height: scaleSize(25),
                          fit: BoxFit.contain,
                        )
                      : LoadImage(
                          'ico_message_smile',
                          width: scaleSize(25),
                          height: scaleSize(25),
                          fit: BoxFit.contain,
                        ),
                  onTap: () {
                    if (state.isShowFace) {
                      state.textFieldNode.requestFocus();
                      dispatch(ChatActionCreator.updateFaceState(false));
                    } else {
                      state.textFieldNode.unfocus();
                      dispatch(ChatActionCreator.updateFaceState(true));
                      dispatch(ChatActionCreator.updateVoiceState(false));
                      dispatch(ChatActionCreator.updateToolsState(false));
                    }
                  },
                ),
              ),
              state.isShowSend
                  ? OpacityButton(
                      child: Container(
                        alignment: Alignment.center,
                        width: scaleSize(60),
                        height: scaleSize(30),
                        margin: EdgeInsets.only(
                            right: 8, bottom: state.isShowVoice ? 9 : 18),
                        child: new Text(
                          '发送',
                          style: new TextStyle(
                              fontSize: 14.0, color: Colors.white),
                        ),
                        decoration: new BoxDecoration(
                          color: MyColors.themeColor,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      onTap: () {
                        if (state.controller.text.isEmpty) {
                          return;
                        }
                        _buildTextMessage(dispatch, state);
                      },
                    )
                  : Container(
                      margin: EdgeInsets.only(
                          right: 8, bottom: state.isShowVoice ? 9 : 18),
                      child: OpacityButton(
                        child: LoadImage(
                          'ico_message_add',
                          width: scaleSize(25),
                          height: scaleSize(25),
                          fit: BoxFit.contain,
                        ),
                        onTap: () {
                          state.textFieldNode.unfocus();
                          if (state.isShowTools) {
                            dispatch(ChatActionCreator.updateToolsState(false));
                          } else {
                            dispatch(ChatActionCreator.updateToolsState(true));
                            dispatch(ChatActionCreator.updateFaceState(false));
                            dispatch(ChatActionCreator.updateVoiceState(false));
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      (state.isShowTools || state.isShowFace)
          ? Container(
              color: state.isShowFace
                  ? MyColors.pageDefaultBackgroundColor
                  : Colors.white,
              height: scaleSize(bottomWidgetHeight),
              child: _bottomWidget(context, state, dispatch),
            )
          : SizedBox(
              height: 0,
            )
    ]),
  );
}

_buildTextMessage(Dispatch dispatch, ChatState state) {
  //这里给每条发送的消息做一个标记，当连续快速发送多条消息的时候根据这个标记来更新该条消息的发送状态；
  String messageFlag = randomBit(10);
  MessageEntity messageEntity = new MessageEntity(
      messageType: getStringFromEnum(NIMMessageType.NIMMessageTypeText),
      text: state.controller.text,
      deliveryState: getStringFromEnum(
          NIMMessageDeliveryState.NIMMessageDeliveryStateDelivering),
      timestamp:
          double.parse(new DateTime.now().millisecondsSinceEpoch.toString())
              .toInt(),
      isOutgoingMsg: true,
      senderName: '',
      localExt: {'messageFlag': messageFlag});
  List<MessageEntity> messageList = state.messageList;
  messageList.add(messageEntity);
  dispatch(ChatActionCreator.updateMessageList(messageList));
  dispatch(ChatActionCreator.updateSendState(false));
  _sendMessage(dispatch, state, messageFlag, messageList);
  state.controller.clear();
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 发送消息
_sendMessage(Dispatch dispatch, ChatState state, String messageFlag,
    List<MessageEntity> messageList,
    {bool isResend = false}) {
  flutterNimPlugin
      .sendTextMessage(
          account: state.sessionId,
          message: state.controller.text,
          messageFlag: messageFlag)
      .then((MessageEntity messageEntity) async {
    if (messageEntity != null) {
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].localExt != null &&
            messageList[i].localExt['messageFlag'] == messageFlag) {
          messageList[i].deliveryState = getStringFromEnum(
              NIMMessageDeliveryState.NIMMessageDeliveryStateDeliveried);
          break;
        }
      }
      dispatch(ChatActionCreator.updateMessageList(messageList));
      await Future.delayed(Duration(milliseconds: 200));
      state.scrollController
          .jumpTo(state.scrollController.position.maxScrollExtent);
    }
  });
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 发送图片消息
_sendImageMessage(String path, Dispatch dispatch, ChatState state) {
  //这里给每条发送的消息做一个标记，当连续快速发送多条消息的时候根据这个标记来更新该条消息的发送状态；
  String messageFlag = randomBit(10);
  MessageEntity messageEntity = new MessageEntity(
      messageType: getStringFromEnum(NIMMessageType.NIMMessageTypeImage),
      deliveryState: getStringFromEnum(
          NIMMessageDeliveryState.NIMMessageDeliveryStateDelivering),
      timestamp:
          double.parse(new DateTime.now().millisecondsSinceEpoch.toString())
              .toInt(),
      isOutgoingMsg: true,
      senderName: '',
      localExt: {
        'messageFlag': messageFlag
      },
      messageObject: {
        'path': path,
        'size': {'width': '1080', 'height': '1920'}
      });
  List<MessageEntity> messageList = state.messageList;
  messageList.add(messageEntity);
  dispatch(ChatActionCreator.updateMessageList(messageList));
  dispatch(ChatActionCreator.updateSendState(false));
  flutterNimPlugin
      .sendImageMessage(
          account: state.sessionId, path: path, messageFlag: messageFlag)
      .then((MessageEntity messageEntity) async {
    if (messageEntity != null) {
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].localExt != null &&
            messageList[i].localExt['messageFlag'] == messageFlag) {
          messageList[i].deliveryState = getStringFromEnum(
              NIMMessageDeliveryState.NIMMessageDeliveryStateDeliveried);
          break;
        }
      }
      dispatch(ChatActionCreator.updateMessageList(messageList));
      await Future.delayed(Duration(milliseconds: 200));
      state.scrollController
          .jumpTo(state.scrollController.position.maxScrollExtent);
    }
  });
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 发送语音消息
_sendVoiceMessage(String path, Dispatch dispatch, ChatState state) {
  //这里给每条发送的消息做一个标记，当连续快速发送多条消息的时候根据这个标记来更新该条消息的发送状态；
  String messageFlag = randomBit(10);
  MessageEntity messageEntity = new MessageEntity(
      messageType: getStringFromEnum(NIMMessageType.NIMMessageTypeAudio),
      deliveryState: getStringFromEnum(
          NIMMessageDeliveryState.NIMMessageDeliveryStateDelivering),
      timestamp:
          double.parse(new DateTime.now().millisecondsSinceEpoch.toString())
              .toInt(),
      isOutgoingMsg: true,
      senderName: '',
      localExt: {
        'messageFlag': messageFlag
      },
      messageObject: {
        'url': Platform.isIOS ? path.substring(7, path.length) : path,
        'duration': (duration * 1000).toString()
      });
  List<MessageEntity> messageList = state.messageList;
  messageList.add(messageEntity);
  dispatch(ChatActionCreator.updateMessageList(messageList));
  dispatch(ChatActionCreator.updateSendState(false));
  flutterNimPlugin
      .sendVoiceMessage(
          account: state.sessionId,
          path: path,
          duration: duration * 1000,
          messageFlag: messageFlag)
      .then((MessageEntity messageEntity) async {
    duration = 0;
    if (messageEntity != null) {
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].localExt != null &&
            messageList[i].localExt['messageFlag'] == messageFlag) {
          messageList[i].deliveryState = getStringFromEnum(
              NIMMessageDeliveryState.NIMMessageDeliveryStateDeliveried);
          break;
        }
      }
      dispatch(ChatActionCreator.updateMessageList(messageList));
      await Future.delayed(Duration(milliseconds: 200));
      state.scrollController
          .jumpTo(state.scrollController.position.maxScrollExtent);
    }
  });
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 底部展开
_bottomWidget(BuildContext context, ChatState state, Dispatch dispatch) {
  Widget widget;
  if (state.isShowTools) {
    widget = _toolsWidget(context, state, dispatch);
  } else if (state.isShowFace) {
    widget = _faceWidget(state, dispatch);
  } else if (state.isShowVoice) {}
  return widget;
}

_toolsWidget(BuildContext context, ChatState state, Dispatch dispatch) {
  return UnconstrainedBox(
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          OpacityButton(
              child: LoadImage(
                'ico_picture',
                width: scaleSize(45),
                height: scaleSize(45),
                fit: BoxFit.fill,
              ),
              onTap: () {
                PopupWindowUtil.showPhotoChosen(context,
                    onCallBack: (File file) {
                  _sendImageMessage(
                      file.absolute
                          .toString()
                          .substring(7, file.absolute.toString().length - 1),
                      dispatch,
                      state);
                });
              }),
          Container(
            margin: EdgeInsets.only(top: scaleSize(6)),
            child: Text(
              '图片',
              style: TextStyle(fontSize: setSp(12), color: MyColors.text_gray),
            ),
          )
        ],
      ),
    ),
  );
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: emoji表情
_faceWidget(ChatState state, Dispatch dispatch) {
  return Column(
    children: <Widget>[
      Flexible(
          child: Stack(
        children: <Widget>[
          Offstage(
            offstage: !state.isFaceFirstList,
            child: Swiper(
                autoStart: false,
                circular: false,
                indicator: CircleSwiperIndicator(
                    radius: 3.0,
                    padding: EdgeInsets.only(top: scaleSize(20)),
                    itemColor: MyColors.gray_99,
                    itemActiveColor: MyColors.themeColor),
                children: state.guideFaceList),
          )
        ],
      )),
      SizedBox(
        height: 10,
      ),
    ],
  );
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 聊天消息
_messageListView(
    BuildContext contextParent, ChatState state, Dispatch dispatch) {
  return Container(
      color: MyColors.pageDefaultBackgroundColor,
      child: Column(
        //如果只有一条数据，listView的高度由内容决定了，所以要加列，让listView看起来是满屏的
        children: <Widget>[
          Flexible(
            //外层是Column，所以在Column和ListView之间需要有个灵活变动的控件
            child: RefreshIndicator(
                onRefresh: () async {
                  dispatch(ChatActionCreator.loadMoreMsg());
                },
                child: ListView.builder(
                    controller: state.scrollController,
                    physics: new AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return _messageListViewItem(contextParent, index, state);
                    },
                    //倒置过来的ListView，这样数据多的时候也会显示“底部”（其实是顶部），
                    //因为正常的listView数据多的时候，没有办法显示在顶部最后一条
                    //如果只有一条数据，因为倒置了，数据会显示在最下面，上面有一块空白，
                    //所以应该让listView高度由内容决定
                    shrinkWrap: true,
                    itemCount: state.messageList.length)),
          )
        ],
      ));
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 聊天item
Widget _messageListViewItem(BuildContext context, int index, ChatState state) {
  //list最后一条消息（时间上是最老的），是没有下一条了
  MessageEntity _nextEntity = (index == state.messageList.length - 1)
      ? null
      : state.messageList[index + 1];
  MessageEntity _entity = state.messageList[index];
  return ChatItemWidgets.buildChatListItem(
      _nextEntity, _entity, state.jsonDecodeMap,
      onItemClick: (MessageEntity entity) async {
    String imagePath = '';
    bool isNetImage = entity.messageObject['thumbUrl'] != null &&
        entity.messageObject['thumbUrl'].toString().contains('http');
    if (isNetImage) {
      imagePath = entity.messageObject['thumbUrl'];
    } else {
      imagePath = entity.messageObject['path'];
    }
    if (entity.messageType ==
            getStringFromEnum(NIMMessageType.NIMMessageTypeImage) ||
        entity.messageType == 'image') {
      NavigatorUtils.push(context,
          '${Routes.photoViewPage}?image=${Uri.encodeComponent(imagePath)}');
    }
  });
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 输入框
_enterWidget(BuildContext context, ChatState state, Dispatch dispatch) {
  if (state.isShowVoice) {
    return Container(
      height: scaleSize(44),
      child: Padding(
        padding: EdgeInsets.only(top: scaleSize(4), bottom: scaleSize(4)),
        child: OpacityButton(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                    color: MyColors.pageDefaultBackgroundColor, width: 2)),
            child: Center(
              child: Text('按住 说话'),
            ),
          ),
          onTapDown: () {
            dispatch(ChatActionCreator.updateRecordState(true));
            startCountdownTimer(dispatch);
            eventBus.fire(Constant.resetAudio);
            // 处理结果
            state.flutterSoundRecorder.startRecorder();
          },
          onTapUp: () async {
            dispatch(ChatActionCreator.updateRecordState(false));
            if (state.timer != null) {
              state.timer.cancel();
              dispatch(ChatActionCreator.initTimer(null));
            }
            String path = await state.flutterSoundRecorder.stopRecorder();
            if (duration < 3) {
              Toast.show('录音时间需大于两秒');
            } else {
              // 处理结果
              _sendVoiceMessage(path, dispatch, state);
            }
          },
          onTapCancel: (){
            dispatch(ChatActionCreator.updateRecordState(false));
          },
        ),
      ),
    );
  }
  return Container(
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.only(top: scaleSize(2), bottom: scaleSize(2)),
      child: Material(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: MyColors.pageDefaultBackgroundColor),
          margin: EdgeInsets.only(bottom: scaleSize(7), top: scaleSize(7)),
          child: TextField(
              autofocus: true,
              focusNode: state.textFieldNode,
              textInputAction: TextInputAction.send,
              controller: state.controller,
              keyboardAppearance: Brightness.light,
              style: TextStyle(color: Colors.black, fontSize: 18),
              maxLines: 10,
              minLines: 1,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  border: InputBorder.none,
                  filled: true,
                  hintText: '请输入聊天内容'),
              onChanged: (str) {
                if (str.isNotEmpty) {
                  dispatch(ChatActionCreator.updateSendState(true));
                } else {
                  dispatch(ChatActionCreator.updateSendState(false));
                }
              },
              onEditingComplete: () {
                if (state.controller.text.isEmpty) {
                  return;
                }
                _buildTextMessage(dispatch, state);
              }),
        ),
      ),
    ),
  );
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-24
/// *@Description: 开始计时
void startCountdownTimer(Dispatch dispatch) {
  const oneSec = const Duration(seconds: 1);
  var callback = (timer) {
    duration++;
  };
  dispatch(ChatActionCreator.initTimer(Timer.periodic(oneSec, callback)));
}
