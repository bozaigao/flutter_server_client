import 'package:fish_redux/fish_redux.dart';

class LoginState implements Cloneable<LoginState> {
  String account;
  String pwd;

  @override
  LoginState clone() {
    return LoginState()
      ..account = account
      ..pwd = pwd;
  }
}

LoginState initState(Map<String, dynamic> args) {
  return LoginState()
    ..account = 'epointcustomservice'
    ..pwd = '6727db524883e7a84b2d4b69cbdff1c3';
}
