import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import 'message_model/message_entity.dart';
import 'message_model/nim_user_info.dart';
final String flutterLog = "| Nim | Flutter | ";

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-07
/// *@Description: 字符串转化为枚举类型
T getEnumFromString<T>(Iterable<T> values, String str) {
  return values.firstWhere((f) => f.toString().split('.').last == str,
      orElse: () => null);
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-07
/// *@Description: 枚举类型转化为字符串
String getStringFromEnum<T>(T) {
  if (T == null) {
    return null;
  }

  return T.toString().split('.').last;
}

typedef NimMessageEventListener = void Function(MessageEntity message);
typedef NimSessionEventListener = void Function();
typedef NimKickEventListener = void Function();
typedef NimMessageRetractListener = void Function(dynamic retractedMessage);

class NimEventHandlers {
  static final NimEventHandlers _instance = new NimEventHandlers._internal();

  NimEventHandlers._internal();

  factory NimEventHandlers() => _instance;

  ///接收消息监听
  List<NimMessageEventListener> receiveMessage = [];

  ///会话更新监听
  List<NimSessionEventListener> sessionUpdateMessage = [];

  ///掉线监听
  List<NimKickEventListener> nimKickListener = [];
}

class FlutterNimPlugin {
  static final FlutterNimPlugin _instance = new FlutterNimPlugin.private(
      const MethodChannel('www.guigug.com/flutter_nim_plugin'),
      const LocalPlatform());

  final MethodChannel _channel;
  final Platform _platform;
  final NimEventHandlers eventHanders = new NimEventHandlers();

  @visibleForTesting
  FlutterNimPlugin.private(MethodChannel channel, Platform platform)
      : _channel = channel,
        _platform = platform;

  factory FlutterNimPlugin() => _instance;

  ///消息监听
  addReceiveMessageListener(NimMessageEventListener callback) {
    eventHanders.receiveMessage.add(callback);
    _channel.setMethodCallHandler(_handleMethod);
  }

  removeReceiveMessageListener() {
    eventHanders.receiveMessage.clear();
  }

  ///会话更新监听
  addSessionUpdateListener(NimSessionEventListener callback) {
    eventHanders.sessionUpdateMessage.add(callback);
    _channel.setMethodCallHandler(_handleMethod);
  }

  removeSessionUpdateListener() {
    eventHanders.sessionUpdateMessage.clear();
  }

  ///掉线监听
  addKickListener(NimKickEventListener callback) {
    eventHanders.nimKickListener.add(callback);
    _channel.setMethodCallHandler(_handleMethod);
  }

  removeKickListener() {
    eventHanders.nimKickListener.clear();
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 消息回调
  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onReceiveMessage':
        for (NimMessageEventListener cb in eventHanders.receiveMessage) {
          MessageEntity messageEntity =
              MessageEntity.fromJson(call.arguments[0]);
          cb(messageEntity);
        }
        break;
      case 'onSessionUpdate':
        for (NimSessionEventListener cb in eventHanders.sessionUpdateMessage) {
          cb();
        }
        break;
      case 'onKick':
        for (NimKickEventListener cb in eventHanders.nimKickListener) {
          cb();
        }
        break;
      default:
        throw new UnsupportedError("Unrecognized Event");
    }
    return;
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-08
  /// *@Description: 登录聊天
  Future<dynamic> nimLogin(
      {String account, String token, String appKey}) async {
    Map params = <String, dynamic>{
      "account": account,
      "token": token,
      "appKey": appKey
    };
    return await _channel.invokeMethod('nimLogin', params);
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 发送文本信息
  Future<MessageEntity> sendTextMessage({
    @required String account,
    @required String message,
    String messageFlag,
  }) async {
    Map param = {};
    Map optionMap = {};
    param
      ..addAll(optionMap)
      ..addAll({
        'account': account,
        'type': getStringFromEnum(NIMMessageType.NIMMessageTypeText),
        'message': message,
        'messageFlag': messageFlag,
      });
    dynamic map = await _channel.invokeMethod(
        'sendMessage', param..removeWhere((key, value) => value == null));

    return MessageEntity.fromJson(map);
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 发送图片信息
  Future<MessageEntity> sendImageMessage({
    @required String account,
    @required String path,
    String messageFlag,
  }) async {
    Map param = {};
    Map optionMap = {};
    param
      ..addAll(optionMap)
      ..addAll({
        'account': account,
        'type': getStringFromEnum(NIMMessageType.NIMMessageTypeImage),
        'path': path,
        'messageFlag': messageFlag,
      });

    dynamic map = await _channel.invokeMethod(
        'sendMessage', param..removeWhere((key, value) => value == null));
    return MessageEntity.fromJson(map);
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 发送语音信息
  Future<MessageEntity> sendVoiceMessage({
    @required String account,
    @required String path,
    int duration,
    String messageFlag,
  }) async {
    Map param = {};

    Map optionMap = {};

    param
      ..addAll(optionMap)
      ..addAll({
        'account': account,
        'type': getStringFromEnum(NIMMessageType.NIMMessageTypeAudio),
        'path': path,
        'duration': duration,
        'messageFlag': messageFlag,
      });

    dynamic map = await _channel.invokeMethod(
        'sendMessage', param..removeWhere((key, value) => value == null));
    return MessageEntity.fromJson(map);
  }


  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 进入会话聊天界面
  Future<void> enterConversation({
    @required dynamic target, //(JMSingle | JMGroup)
  }) async {
    if (_platform.isAndroid) {
      Map param = target.toJson();
      await _channel.invokeMethod('enterConversation',
          param..removeWhere((key, value) => value == null));
    }

    return;
  }


  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 获取其他用户基本信息
  Future<NIMUserInfoEntity> getUserInfo(
      {@required String username, String appKey}) async {
    Map userJson = await _channel.invokeMethod(
        'getUserInfo',
        {'username': username, 'appKey': appKey}
          ..removeWhere((key, value) => value == null));
    return NIMUserInfoEntity.fromJson(userJson);
  }



  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 获取所有未读消息条数
  Future<num> getAllUnreadCount() async {
    num unreadCount = await _channel.invokeMethod('getAllUnreadCount');
    return unreadCount;
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-07
  /// *@Description: 设置消息已读
  Future<bool> setMessageHaveRead({
    @required dynamic target,

    /// (NimSingle | NimGroup)
    @required String msgId,
  }) async {
    if (msgId == null || msgId.length == 0 || target == null) {
      return false;
    }

    Map param = target.toJson();
    param["id"] = msgId;
    bool isSuccess = await _channel.invokeMethod('setMessageHaveRead',
        param..removeWhere((key, value) => value == null));

    return isSuccess;
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-02-08
  /// *@Description: 退出登录
  Future<Map> loginOut() async {
    Map params = <String, dynamic>{};
    return await _channel.invokeMethod('loginOut', params);
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-14
  /// *@Description: 获取所有的会话列表数据
  Future<dynamic> getAllSessions() async {
    return await _channel.invokeMethod('getAllSessions');
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-14
  /// *@Description: 获取所有的会话用户信息
  Future<dynamic> getUsersInfo(List<String> userIds) async {
    return await _channel.invokeMethod('getUsersInfo', {"userIds": userIds});
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-16
  /// *@Description: 从本地db获取历史消息数据
  Future<dynamic> fetchLocalMessageHistory(
      {String sessionId, int limit = 30}) async {
    return await _channel.invokeMethod(
        'fetchLocalMessageHistory', {'sessionId': sessionId, 'limit': limit});
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-15
  /// *@Description: 获取历史消息
  Future<dynamic> fetchMessageHistory(
      {String sessionId, int limit = 30}) async {
    return await _channel.invokeMethod(
        'fetchMessageHistory', {'sessionId': sessionId, 'limit': limit});
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-14
  /// *@Description: 重置消息
  void resetMessage() {
    _channel.invokeMethod('resetMessage');
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-17
  /// *@Description: 设置某一个会话消息全部已读
  void markAllMessagesReadInSession(String sessionId) {
    _channel
        .invokeMethod('markAllMessagesReadInSession', {'sessionId': sessionId});
  }

  /// *@author 何晏波
  /// *@QQ 1054539528
  /// *@date 2020-04-17
  /// *@Description: 设置所有会话消息已读
  void markAllMessagesRead() {
    _channel.invokeMethod('markAllMessagesRead');
  }
}
