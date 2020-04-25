import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/nim_user_info.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/recent_session_entity.dart';

class SessionState implements Cloneable<SessionState> {
  EasyRefreshController controller;
  List<RecentSessionEntity> sessions;
  List<NIMUserEntity> usersInfo;

  //为filter搜索保持最初的数据
  List<RecentSessionEntity> sessionsTmp;
  List<NIMUserEntity> usersInfoTmp;
  String filterStr;
  int pageSize;
  int index;

  @override
  SessionState clone() {
    return SessionState()
      ..controller = controller
      ..sessions = sessions
      ..usersInfo = usersInfo
      ..pageSize = pageSize
      ..index = index
      ..filterStr = filterStr
      ..sessionsTmp = sessionsTmp
      ..usersInfoTmp = usersInfoTmp;
  }
}

SessionState initState(Map<String, dynamic> args) {
  return SessionState()
    ..controller = EasyRefreshController()
    ..sessions = []
    ..usersInfo = []
    ..sessionsTmp = []
    ..usersInfoTmp = []
    ..pageSize = 150
    ..index = 0
    ..filterStr = '';
}

class SessionPageData {
  final String account;
  final String pwd;

  const SessionPageData({this.account, this.pwd});
}
