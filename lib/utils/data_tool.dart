import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:fish_redux/fish_redux.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'common.dart';

void judgeLogin({@required Function successCallback, Function failCallback}) {
  String loginToken = SpUtil.getString(Constant.loginToken);

  if (loginToken != null && loginToken.length != 0) {
    if (successCallback != null) {
      successCallback();
    }
  } else if (failCallback != null) {
    failCallback();
  }
}

String randomBit(int len) {
  String scopeF = '123456789'; //首位
  String scopeC = '0123456789'; //中间
  String result = '';
  for (int i = 0; i < len; i++) {
    if (i == 1) {
      result = scopeF[Random().nextInt(scopeF.length)];
    } else {
      result = result + scopeC[Random().nextInt(scopeC.length)];
    }
  }
  return result;
}

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-12
/// *@Description: md5 加密
String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  // 这里其实就是 digest.toString()
  return hex.encode(digest.bytes);
}


/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-15
/// *@Description: 格式化时间
String transTime(timestamps) {
  String time =
      DateTime.fromMillisecondsSinceEpoch(timestamps).toLocal().toString();
  return time.substring(0, time.indexOf('.'));
}
