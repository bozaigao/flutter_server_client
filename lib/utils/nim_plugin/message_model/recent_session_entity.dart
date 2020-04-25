import 'dart:io';
import 'dart:convert' as convert;
import 'package:flutter_server_client/utils/nim_plugin/message_model/message_entity.dart';

/// *@filename recent_session_entity.dart
/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-14
/// *@Description: 网易云信最近会话列表实体类
class RecentSessionEntity {
  //最近会话
  NIMSessionEntity session;

  //最后一条消息
  MessageEntity lastMessage;

  //未读消息数，为保证线程安全，请在主线程中获取
  int unreadCount;

  //本地扩展
  dynamic localExt;

  RecentSessionEntity(
      {this.session, this.lastMessage, this.localExt, this.unreadCount});

  RecentSessionEntity.fromJson(Map<dynamic, dynamic> map)
      : this(
          session: Platform.isIOS
              ? NIMSessionEntity.fromJson(map['session'])
              : NIMSessionEntity(
                  sessionId: map['contactId'], sessionType: map['sessionType']),
          lastMessage: Platform.isIOS
              ? MessageEntity.fromJson(map['lastMessage'])
              : MessageEntity(
                  text: map['msgType'] == 'text' ? map['content'] : '',
                  timestamp: map['time'],
                  messageType: map['msgType'],
                  messageObject: map['msgType'] == 'custom'
                      ? {
                          'type': convert
                              .jsonDecode(map['attachment']['content'])['type']
                        }
                      : null),
          unreadCount: Platform.isIOS
              ? int.parse(map['unreadCount'])
              : map['unreadCount'],
          localExt: map['localExt'],
        );

  // Currently not used
  Map<String, dynamic> toJson() {
    return {
      'session': session.toJson(),
      'lastMessage': lastMessage.toJson(),
      'unreadCount': unreadCount,
      'localExt': localExt,
    };
  }
}

///消息会话
class NIMSessionEntity {
  String sessionId;
  String sessionType;

  NIMSessionEntity({
    this.sessionId,
    this.sessionType,
  });

  NIMSessionEntity.fromJson(Map<dynamic, dynamic> map)
      : this(
          sessionId: map['sessionId'],
          sessionType: map['sessionType'],
        );

  // Currently not used
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'sessionType': sessionType,
    };
  }
}
