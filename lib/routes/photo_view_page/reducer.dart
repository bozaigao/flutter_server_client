import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<PhotoViewState> buildReducer() {
  return asReducer(
    <Object, Reducer<PhotoViewState>>{
      PhotoViewAction.action: _onAction,
    },
  );
}

PhotoViewState _onAction(PhotoViewState state, Action action) {
  final PhotoViewState newState = state.clone();
  return newState;
}
