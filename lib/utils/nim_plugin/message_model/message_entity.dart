import 'dart:io';
import 'dart:convert' as convert;

/// *@filename message_entity.dart
/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-11
/// *@Description: 网易云信消息类实体
import 'package:flutter/material.dart';

///消息类型
enum NIMMessageType {
  NIMMessageTypeText,
  NIMMessageTypeImage,
  NIMMessageTypeAudio,
  NIMMessageTypeCustom
}

///会话类型
enum NIMSessionType {
  ///点对点
  NIMSessionTypeP2P,
}

///消息发送状态
enum NIMMessageDeliveryState {
  ///消息发送失败
  NIMMessageDeliveryStateFailed,

  ///消息发送中
  NIMMessageDeliveryStateDelivering,

  ///消息发送成功
  NIMMessageDeliveryStateDeliveried
}

///消息发送端的机器类型
enum NIMLoginClientType {
  ///未知类型
  NIMLoginClientTypeUnknown,

  ///Android
  NIMLoginClientTypeAOS,

  ///iOS
  NIMLoginClientTypeiOS,
}

///消息附件下载状态
enum NIMMessageAttachmentDownloadState {
  ///附件需要进行下载 (有附件但并没有下载过)
  NIMMessageAttachmentDownloadStateNeedDownload,

  ///附件收取失败 (尝试下载过一次并失败)
  NIMMessageAttachmentDownloadStateFailed,

  ///附件下载中
  NIMMessageAttachmentDownloadStateDownloading,

  ///附件下载成功/无附件
  NIMMessageAttachmentDownloadStateDownloaded
}

class MessageEntity {
  ///消息类型
  String messageType;

  ///消息来源
  String from;

  ///消息所属会话
  NIMSessionEntity session;

  ///消息ID,唯一标识
  String messageId;

  ///消息文本
  String text;

  ///消息附件内容
  dynamic messageObject;

  ///消息设置
  NIMMessageSettingEntity setting;

  ///消息反垃圾配置
  dynamic antiSpamOption;

  ///消息推送文案,长度限制500字
  String apnsContent;

  ///消息推送Payload
  Map apnsPayload;

  ///指定成员推送选项,通过这个选项进行一些更复杂的推送设定，目前只能在群会话中使用
  dynamic apnsMemberOption;

  ///服务器扩展
  Map remoteExt;

  ///客户端本地扩展
  Map localExt;

  ///消息拓展字段,服务器下发的消息拓展字段，并不在本地做持久化，目前只有聊天室中的消息才有该字段
  dynamic messageExt;

  ///消息发送时间
  int timestamp;

  ///消息投递状态 仅针对发送的消息
  String deliveryState;

  ///消息附件下载状态 仅针对收到的消息
  String attachmentDownloadState;

  ///是否是收到的消息，由于有漫游消息的概念,所以自己发出的消息漫游下来后仍旧是"收到的消息",这个字段用于消息出错是时判断需要重发还是重收
  bool isReceivedMsg;

  ///是否是往外发的消息
  bool isOutgoingMsg;

  ///消息是否被播放过,修改这个属性,后台会自动更新db中对应的数据
  bool isPlayed;

  ///消息是否标记为已删除
  bool isDeleted;

  ///对端是否已读
  bool isRemoteRead;

  ///消息发送者名字
  String senderName;

  ///发送者客户端类型
  String senderClientType;

  MessageEntity(
      {@required this.messageType,
      @required this.from,
      @required this.messageId,
      this.session,
      this.text,
      this.messageObject,
      this.setting,
      this.antiSpamOption,
      this.apnsContent,
      this.apnsPayload,
      this.apnsMemberOption,
      this.remoteExt,
      this.localExt,
      this.messageExt,
      this.timestamp,
      this.deliveryState,
      this.attachmentDownloadState,
      this.isReceivedMsg,
      this.isOutgoingMsg,
      this.isPlayed,
      this.isDeleted,
      this.isRemoteRead,
      this.senderName,
      this.senderClientType});

  MessageEntity.fromJson(Map<dynamic, dynamic> map)
      : this(
            messageType: Platform.isIOS ? map['messageType'] : map['msgType'],
            from: Platform.isIOS ? map['from'] : map['fromAccount'],
            messageId: Platform.isIOS ? map['messageId'] : map['uuid'],
            session: Platform.isIOS
                ? NIMSessionEntity.fromJson(map['session'])
                : NIMSessionEntity(
                    sessionId: map['sessionId'],
                    sessionType: map['sessionType']),
            text: Platform.isIOS ? map['text'] : map['content'],
            messageObject: Platform.isIOS
                ? map['messageObject']
                : (map['msgType'] == 'custom'
                    ? convert.jsonDecode(map['attachment']['content'])
                    : map['msgType'] == 'image'
                        ? {
                            'size': {
                              'width': map['attachment']['width'].toString(),
                              'height': map['attachment']['height'].toString()
                            },
                            'thumbUrl': map['attachment']['thumbUrl']
                          }
                        : (map['msgType'] == 'audio'
                            ? {
                                'duration': map['attachment']['duration'].toString(),
                                'url': map['attachment']['url']
                              }
                            : null)),
            setting: Platform.isIOS
                ? NIMMessageSettingEntity.fromJson(map['setting'])
                : null,
            antiSpamOption: map['antiSpamOption'],
            apnsContent: map['apnsContent'],
            apnsPayload: map['apnsPayload'],
            apnsMemberOption: map['apnsMemberOption'],
            remoteExt: map['remoteExt'],
            localExt: Platform.isIOS ? map['localExt'] : map['localExtension'],
            messageExt: map['messageExt'],
            timestamp: Platform.isIOS
                ? (double.parse(map['timestamp']) * 1000).toInt()
                : map['time'],
            deliveryState:
                Platform.isIOS ? map['deliveryState'] : map['status'],
            attachmentDownloadState: map['attachmentDownloadState'],
            isReceivedMsg: map['isReceivedMsg'],
            isOutgoingMsg: Platform.isIOS
                ? map['isOutgoingMsg']
                : map['direct'].toString().toLowerCase() != "in",
            isPlayed: map['isPlayed'],
            isDeleted: map['isDeleted'],
            isRemoteRead: map['isRemoteRead'],
            senderName: Platform.isIOS ? map['senderName'] : map['fromNick'],
            senderClientType: Platform.isIOS
                ? map['senderClientType']
                : map['fromClientType'].toString());

  // Currently not used
  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'from': from,
      'messageId': messageId,
      'session': session.toJson(),
      'text': text,
      'messageObject': messageObject,
      'setting': setting.toJson(),
      'antiSpamOption': antiSpamOption,
      'apnsContent': apnsContent,
      'apnsPayload': apnsPayload,
      'apnsMemberOption': apnsMemberOption,
      'remoteExt': remoteExt,
      'localExt': localExt,
      'messageExt': messageExt,
      'timestamp': timestamp,
      'deliveryState': deliveryState,
      'attachmentDownloadState': attachmentDownloadState,
      'isReceivedMsg': isReceivedMsg,
      'isOutgoingMsg': isOutgoingMsg,
      'isPlayed': isPlayed,
      'isDeleted': isDeleted,
      'isRemoteRead': isRemoteRead,
      'senderName': senderName,
      'senderClientType': senderClientType
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

///消息设置
class NIMMessageSettingEntity {
  ///消息是否允许在消息历史中拉取
  bool historyEnabled;

  ///消息是否支持漫游
  bool roamingEnabled;

  ///消息是否支持多端同步
  bool syncEnabled;

  ///消息是否需要被计入未读计数
  bool shouldBeCounted;

  ///消息是否需要推送
  bool apnsEnabled;

  ///推送是否需要带前缀(一般为昵称)
  bool apnsWithPrefix;

  ///是否需要抄送
  bool routeEnabled;

  ///其他群成员收到此消息是否需要发送已读回执
  bool teamReceiptEnabled;

  ///消息是否支持离线
  bool persistEnable;

  ///消息对应的场景
  String scene;

  ///消息是否需要刷新到session服务。默认：是
  bool isSessionUpdate;

  NIMMessageSettingEntity({
    this.historyEnabled,
    this.roamingEnabled,
    this.syncEnabled,
    this.shouldBeCounted,
    this.apnsEnabled,
    this.apnsWithPrefix,
    this.routeEnabled,
    this.teamReceiptEnabled,
    this.persistEnable,
    this.scene,
    this.isSessionUpdate,
  });

  NIMMessageSettingEntity.fromJson(Map<dynamic, dynamic> map)
      : this(
          historyEnabled: map['historyEnabled'],
          roamingEnabled: map['roamingEnabled'],
          syncEnabled: map['syncEnabled'],
          shouldBeCounted: map['shouldBeCounted'],
          apnsEnabled: map['apnsEnabled'],
          apnsWithPrefix: map['apnsWithPrefix'],
          routeEnabled: map['routeEnabled'],
          teamReceiptEnabled: map['teamReceiptEnabled'],
          persistEnable: map['persistEnable'],
          scene: map['scene'],
          isSessionUpdate: map['isSessionUpdate'],
        );

  // Currently not used
  Map<String, dynamic> toJson() {
    return {
      'historyEnabled': historyEnabled,
      'roamingEnabled': roamingEnabled,
      'syncEnabled': syncEnabled,
      'shouldBeCounted': shouldBeCounted,
      'apnsEnabled': apnsEnabled,
      'apnsWithPrefix': apnsWithPrefix,
      'routeEnabled': routeEnabled,
      'teamReceiptEnabled': teamReceiptEnabled,
      'persistEnable': persistEnable,
      'roamingEnabled': roamingEnabled,
      'scene': scene,
      'isSessionUpdate': isSessionUpdate,
    };
  }
}
