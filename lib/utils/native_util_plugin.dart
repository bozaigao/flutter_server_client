import 'package:flutter/services.dart';

/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-04-14
/// *@Description: 原生模块插件
const nativeUtilPlugin = const MethodChannel('www.guigug.com/native_util_plugin');
typedef ScreenLockChangeEventListener = void Function();
List<ScreenLockChangeEventListener> screenLockListener = [];


Future<bool> checkNetworkAvailable() async {
  bool result = await nativeUtilPlugin.invokeMethod('checkNetworkAvailable');
  return result;
}


void addScreenLockListener(ScreenLockChangeEventListener callback) async {
  screenLockListener.add(callback);
  nativeUtilPlugin.invokeMethod('listenerScreenLock');
  nativeUtilPlugin.setMethodCallHandler(_handleMethod);
}

void removeScreenLockListener() {
  screenLockListener.clear();
}



/// *@author 何晏波
/// *@QQ 1054539528
/// *@date 2020-02-07
/// *@Description: 原生回调监听
Future<void> _handleMethod(MethodCall call) async {
  switch (call.method) {
    case 'onScreenLockChange':
      for (ScreenLockChangeEventListener cb in screenLockListener) {
        cb();
      }
      break;
    default:
      throw new UnsupportedError("Unrecognized Event");
  }
  return;
}