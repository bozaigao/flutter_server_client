import 'package:fish_redux/fish_redux.dart';

//TODO replace with your own action
enum LoginAction { updateAccount, updatePwd }

class LoginActionCreator {
  static Action updateAccount(String account) {
    return Action(LoginAction.updateAccount, payload: account);
  }

  static Action updatePwd(String pwd) {
    return Action(LoginAction.updatePwd, payload: pwd);
  }
}
