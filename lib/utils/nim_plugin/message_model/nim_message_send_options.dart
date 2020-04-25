class CustomMessageConfig {
  ///该消息是否要保存到服务器，如果为false，通过 MsgService#pullMessageHistory(IMMessage, int, boolean)
  bool enableHistory = true;

  ///该消息是否需要漫游。如果为false，一旦某一个客户端收取过该条消息，其他端将不会再漫游到该条消息。
  bool enableRoaming = true;

  ///多端同时登录时，发送一条自定义消息后，是否要同步到其他同时登录的客户端。
  bool enableSelfSync = true;

  ///该消息是否要消息提醒，如果为true，那么对方收到消息后，系统通知栏会有提醒。
  bool enablePush = true;

  ///该消息是否需要推送昵称（针对iOS客户端有效），如果为true，那么对方收到消息后，iOS端将显示推送昵称。
  bool enablePushNick = true;

  ///该消息是否要计入未读数，如果为true，那么对方收到消息后，最近联系人列表中未读数加1。
  bool enableUnreadCount = true;

  ///该消息是否支持路由，如果为true，默认按照app的路由开关（如果有配置抄送地址则将抄送该消息）
  bool enableRoute = true;

  ///该消息是否要存离线
  bool enablePersist = true;

  Map toJson() {
    return {
      'enableHistory': enableHistory,
      'enableRoaming': enableRoaming,
      'enableSelfSync': enableSelfSync,
      'enablePush': enablePush,
      'enablePushNick': enablePushNick,
      'enableUnreadCount': enableUnreadCount,
      'enableRoute': enableRoute,
      'enablePersist': enablePersist,
    };
  }

  CustomMessageConfig.fromJson(Map<dynamic, dynamic> json)
      : enableHistory = json['enableHistory'],
        enableRoaming = json['enableRoaming'],
        enableSelfSync = json['enableSelfSync'],
        enablePush = json['enablePush'],
        enablePushNick = json['enablePushNick'],
        enableUnreadCount = json['enableUnreadCount'],
        enableRoute = json['enableRoute'],
        enablePersist = json['enablePersist'];
}
