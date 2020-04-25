import 'package:fish_redux/fish_redux.dart';
import 'package:flustars/flustars.dart' hide ScreenUtil;
import 'package:flutter/material.dart';
import 'package:flutter_server_client/constants/constants.dart';
import 'package:flutter_server_client/res/colors.dart';
import 'package:flutter_server_client/routes/login_page/action.dart';
import 'package:flutter_server_client/utils/common.dart';
import 'package:flutter_server_client/utils/native_util_plugin.dart';
import 'package:flutter_server_client/utils/permission.dart';
import 'package:flutter_server_client/utils/progress.dart';
import 'package:flutter_server_client/utils/routes/fluro_navigator.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:flutter_server_client/utils/screen_util.dart';
import 'package:flutter_server_client/utils/toast.dart';
import 'package:flutter_server_client/widgets/load_image.dart';
import 'package:flutter_server_client/widgets/opacity_button.dart';
import '../../app.dart';
import 'state.dart';

Widget buildView(LoginState state, Dispatch dispatch, ViewService viewService) {
  initScreenUtil(viewService.context);

  return Material(
    child: Scaffold(
      body: FlatButton(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        padding: EdgeInsets.all(0),
        onPressed: () {
          FocusScope.of(viewService.context).requestFocus(FocusNode());
        },
        child: Container(
          color: Colors.white,
          child: SafeArea(
              child: Padding(
            padding: EdgeInsets.only(
                top: scaleSize(100), left: scaleSize(32), right: scaleSize(32)),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '欢迎登录客服聊天系统',
                    style: TextStyle(
                        color: Color(0xff153971), fontSize: setSp(24)),
                  ),
                  Container(
                    width: ScreenUtil.screenWidthDp,
                    height: scaleSize(50),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1, color: Color(0xffecf0f9)))),
                    margin: EdgeInsets.only(top: scaleSize(50)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: TextField(
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: state.account,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            offset: state.account.length)))),
                            keyboardAppearance: Brightness.light,
                            cursorColor: MyColors.themeColor,
                            style: TextStyle(
                                color: Color(0xff072b2b), fontSize: setSp(16)),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '请输入聊天账号',
                              hintStyle: TextStyle(
                                  color: Color(0xff999999),
                                  fontSize: setSp(16)),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (String value) {
                              dispatch(LoginActionCreator.updateAccount(value));
                            },
                          ),
                          width: scaleSize(260),
                          height: scaleSize(50),
                        ),
                        state.account.isNotEmpty
                            ? Opacity(
                                opacity: 0.3,
                                child: GestureDetector(
                                  onTap: () {
                                    dispatch(
                                        LoginActionCreator.updateAccount(''));
                                  },
                                  child: LoadImage(
                                    'ico_close',
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                              )
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenUtil.screenWidthDp,
                    height: scaleSize(50),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(width: 1, color: Color(0xffecf0f9))),
                    ),
                    margin: EdgeInsets.only(top: scaleSize(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: scaleSize(260),
                          height: scaleSize(50),
                          child: TextField(
                            obscureText: true,
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: state.pwd,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
                                            offset: state.pwd.length)))),
                            keyboardAppearance: Brightness.light,
                            cursorColor: MyColors.themeColor,
                            style: TextStyle(
                                color: Color(0xff072b2b), fontSize: setSp(16)),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: '请输入密码',
                              hintStyle: TextStyle(
                                  color: Color(0xff999999),
                                  fontSize: setSp(16)),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (String value) {
                              dispatch(LoginActionCreator.updatePwd(value));
                            },
                          ),
                        ),
                        state.pwd.isNotEmpty
                            ? Opacity(
                                opacity: 0.3,
                                child: GestureDetector(
                                  onTap: () {
                                    dispatch(LoginActionCreator.updatePwd(''));
                                  },
                                  child: LoadImage(
                                    'ico_close',
                                    width: 15,
                                    height: 15,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                              )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: scaleSize(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        OpacityButton(
                          onTap: () {
                            requestReadAndWritePermission().then((res) async {
                              if (res) {
                                checkNetworkAvailable().then((isConnected) {
                                  if (isConnected) {
                                    showProgress(viewService.context,
                                        title: '登录中...');
                                    //网易云信账号登录
                                    flutterNimPlugin
                                        .nimLogin(
                                            account: state.account,
                                            token: state.pwd,
                                            appKey: Constants.APP_KEY)
                                        .then((res) async {
                                      hideProgress(viewService.context);
                                      Toast.show('登录成功');
                                      await SpUtil.putObject(
                                          Constant.accountInfo, {
                                        'account': state.account,
                                        'pwd': state.pwd
                                      });
                                      await SpUtil.putBool(
                                          Constant.loginState, true);
                                      NavigatorUtils.push(viewService.context,
                                          Routes.sessionPage,
                                          replace: true, clearStack: true);
                                    }).catchError((err) {
                                      hideProgress(viewService.context);
                                      Toast.show('账号或密码错误');
                                    });
                                  } else {
                                    Toast.show('请检查网络');
                                  }
                                });
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(scaleSize(25)),
                                color: MyColors.themeColor),
                            child: Center(
                              child: Text(
                                '登录',
                                style: TextStyle(
                                    fontSize: setSp(18), color: Colors.white),
                              ),
                            ),
                            width: scaleSize(305),
                            height: scaleSize(50),
                          ),
                          disabled: state.account.isEmpty || state.pwd.isEmpty,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
        ),
      ),
    ),
  );
}
