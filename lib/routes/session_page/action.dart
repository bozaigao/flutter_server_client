import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/nim_user_info.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/recent_session_entity.dart';

//TODO replace with your own action
enum SessionAction { onRefresh, refresh,filterRefresh, onLoadMore, loadMore, updateIndex,updateFilter }

class SessionActionCreator {


  static Action updateFilter(String filter) {
    return Action(SessionAction.updateFilter,payload: filter);
  }

  static Action onRefresh() {
    return const Action(SessionAction.onRefresh);
  }

  static Action filterRefresh(
      List<RecentSessionEntity> sessions,
      List<NIMUserEntity> usersInfo,
      ) {
    return Action(SessionAction.filterRefresh,
        payload: {"sessions": sessions, "usersInfo": usersInfo});
  }

  static Action refresh(
    List<RecentSessionEntity> sessions,
    List<NIMUserEntity> usersInfo,
  ) {
    return Action(SessionAction.refresh,
        payload: {"sessions": sessions, "usersInfo": usersInfo});
  }

  static Action onLoadMore() {
    return const Action(SessionAction.onLoadMore);
  }

  static Action loadMore(List<RecentSessionEntity> sessions) {
    return Action(SessionAction.loadMore, payload: sessions);
  }

  static Action updateIndex(int index) {
    return Action(SessionAction.updateIndex, payload: index);
  }
}
