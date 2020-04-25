/// 创建应用的根 Widget
/// 1. 创建一个简单的路由，并注册页面
/// 2. 对所需的页面进行和 AppStore 的连接
/// 3. 对所需的页面进行 AOP 的增强

import 'package:event_bus/event_bus.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_server_client/routes/login_page/page.dart';
import 'package:flutter_server_client/utils/log_utils.dart';
import 'package:flutter_server_client/utils/nim_plugin/flutter_nim_plugin.dart';
import 'package:flutter_server_client/utils/routes/application.dart';
import 'package:flutter_server_client/utils/routes/routers.dart';
import 'package:oktoast/oktoast.dart';

EventBus eventBus = EventBus();
//网易云信聊天插件
FlutterNimPlugin flutterNimPlugin = FlutterNimPlugin();

Widget createApp() {
  final router = Router();
  Routes.configureRoutes(router);
  Application.router = router;
  Log.init();
  dynamic loginPage = LoginPage();

  return OKToast(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginPage.buildPage(null),
      onGenerateRoute: Application.router.generator,
    ),
  );
}
