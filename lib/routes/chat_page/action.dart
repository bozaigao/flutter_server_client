import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';

//TODO replace with your own action
enum ChatAction {
  resetShow,
  updateSendState,
  updateVoiceState,
  updateFaceState,
  updateToolsState,
  updateFaceFirstList,
  updateMessageList,
  updateGuideFaceList,
  initJsonCodeMap,
  initJsonDecodeMap,
  loadMoreMsg,
  updateIni,
  initTimer,
  updateRecordState
}

class ChatActionCreator {
  static Action updateRecordState(bool recording) {
    return Action(ChatAction.updateRecordState, payload: recording);
  }

  static Action initTimer(Timer timer) {
    return Action(ChatAction.initTimer, payload: timer);
  }

  static Action updateInit(bool init) {
    return Action(ChatAction.loadMoreMsg, payload: init);
  }

  static Action loadMoreMsg() {
    return const Action(ChatAction.loadMoreMsg);
  }

  static Action resetShow() {
    return const Action(ChatAction.resetShow);
  }

  static Action updateSendState(bool state) {
    return Action(ChatAction.updateSendState, payload: state);
  }

  static Action updateVoiceState(bool state) {
    return Action(ChatAction.updateVoiceState, payload: state);
  }

  static Action updateFaceState(bool state) {
    return Action(ChatAction.updateFaceState, payload: state);
  }

  static Action updateToolsState(bool state) {
    return Action(ChatAction.updateToolsState, payload: state);
  }

  static Action updateFaceFirstList(bool state) {
    return Action(ChatAction.updateFaceFirstList, payload: state);
  }

  static Action updateMessageList(List<MessageEntity> messageList) {
    return Action(ChatAction.updateMessageList, payload: messageList);
  }

  static Action updateGuideFaceList(List<Widget> guideFaceList) {
    return Action(ChatAction.updateGuideFaceList, payload: guideFaceList);
  }

  static Action initJsonCodeMap(Map<String, dynamic> jsonCodeMap) {
    return Action(ChatAction.initJsonCodeMap, payload: jsonCodeMap);
  }

  static Action initJsonDecodeMap(Map<String, dynamic> jsonDecodeMap) {
    return Action(ChatAction.initJsonDecodeMap, payload: jsonDecodeMap);
  }
}
