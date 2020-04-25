import 'package:fish_redux/fish_redux.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter_server_client/constants/constants.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/native_util_plugin.dart';
import 'package:flutter_server_client/utils/progress.dart';
import 'package:flutter_server_client/utils/routes/fluro_navigator.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:flutter_server_client/utils/toast.dart';
import '../../app.dart';
import 'state.dart';

Effect<LoginState> buildEffect() {
  return combineEffects(
      <Object, Effect<LoginState>>{Lifecycle.initState: _initState});
}

void _initState(Action action, Context<LoginState> ctx) async {
  //读取缓存数据
  await SpUtil.getInstance();
  SpUtil.getObj(Constant.accountInfo, (objc) {
    if (objc != null) {
      checkNetworkAvailable().then((isConnected) {
        if (isConnected) {
          showProgress(ctx.context, title: '登录中...');
          //网易云信账号登录
          flutterNimPlugin
              .nimLogin(
                  account: objc['account'],
                  token: objc['pwd'],
                  appKey: Constants.APP_KEY)
              .then((res) async {
            hideProgress(ctx.context);
            Toast.show('登录成功');
            NavigatorUtils.push(ctx.context, Routes.sessionPage,
                replace: true, clearStack: true);
          }).catchError((err) {
            hideProgress(ctx.context);
            Toast.show('账号或密码错误');
          });
        } else {
          Toast.show('请检查网络');
        }
      });
    }
  });
}
