import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_server_client/utils/nim_plugin/message_model/recent_session_entity.dart';

import 'action.dart';
import 'state.dart';

Reducer<SessionState> buildReducer() {
  return asReducer(
    <Object, Reducer<SessionState>>{
      SessionAction.refresh: _refresh,
      SessionAction.filterRefresh: _filterRefresh,
      SessionAction.loadMore: _loadMore,
      SessionAction.updateIndex: _updateIndex,
      SessionAction.updateFilter: _updateFilter,
    },
  );
}

SessionState _updateFilter(SessionState state, Action action) {
  return state.clone()..filterStr = action.payload;
}

SessionState _filterRefresh(SessionState state, Action action) {
  return state.clone()
    ..sessions = action.payload['sessions']
    ..usersInfo = action.payload['usersInfo'];
}

SessionState _refresh(SessionState state, Action action) {
  return state.clone()
    ..sessions = action.payload['sessions']
    ..sessionsTmp = action.payload['sessions']
    ..usersInfo = action.payload['usersInfo']
    ..usersInfoTmp = action.payload['usersInfo'];
}

SessionState _loadMore(SessionState state, Action action) {
  List<RecentSessionEntity> sessions = state.clone().sessions;
  sessions.addAll(action.payload);
  return state.clone()..sessions = sessions;
}

SessionState _updateIndex(SessionState state, Action action) {
  return state.clone()..index = action.payload;
}
