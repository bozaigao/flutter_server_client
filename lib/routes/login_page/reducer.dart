import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<LoginState> buildReducer() {
  return asReducer(
    <Object, Reducer<LoginState>>{
      LoginAction.updateAccount: _updateAccount,
      LoginAction.updatePwd: _updatePwd,
    },
  );
}

LoginState _updateAccount(LoginState state, Action action) {
  return state.clone()..account = action.payload;
}

LoginState _updatePwd(LoginState state, Action action) {
  return state.clone()..pwd = action.payload;
}
