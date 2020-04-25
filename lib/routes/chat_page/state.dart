import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_server_client/utils/flutter_sound/flutter_sound.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';

class ChatState implements Cloneable<ChatState> {
  bool isShowSend;
  bool isShowVoice;
  bool isShowFace;
  bool isShowTools;
  bool isFaceFirstList;
  FocusNode textFieldNode;
  TextEditingController controller;
  List<MessageEntity> messageList;
  List<Widget> guideFaceList;
  ScrollController scrollController;
  Map<String, dynamic> jsonCodeMap;
  Map<String, dynamic> jsonDecodeMap;
  String sessionId;
  String nickName;
  FlutterSound flutterSoundRecorder;
  Timer timer;
  bool recording;

  @override
  ChatState clone() {
    return ChatState()
      ..isShowSend = isShowSend
      ..isShowVoice = isShowVoice
      ..isShowFace = isShowFace
      ..isShowTools = isShowTools
      ..textFieldNode = textFieldNode
      ..controller = controller
      ..isFaceFirstList = isFaceFirstList
      ..messageList = messageList
      ..guideFaceList = guideFaceList
      ..scrollController = scrollController
      ..jsonCodeMap = jsonCodeMap
      ..jsonDecodeMap = jsonDecodeMap
      ..sessionId = sessionId
      ..nickName = nickName
      ..flutterSoundRecorder = flutterSoundRecorder
      ..timer = timer
      ..recording = recording;
  }
}

ChatState initState(ChatPageData chatPageData) {
  return ChatState()
    ..isShowSend = false
    ..isShowVoice = false
    ..isShowFace = false
    ..isShowTools = false
    ..textFieldNode = FocusNode()
    ..controller = new TextEditingController()
    ..isFaceFirstList = true
    ..messageList = new List()
    ..guideFaceList = new List()
    ..scrollController = new ScrollController()
    ..jsonCodeMap = new Map()
    ..jsonDecodeMap = new Map()
    ..sessionId = chatPageData.sessionId
    ..nickName = chatPageData.nickName
    ..flutterSoundRecorder = new FlutterSound()
    ..recording = false;
}

class ChatPageData {
  final String sessionId;
  final String nickName;

  const ChatPageData({this.sessionId, this.nickName});
}
