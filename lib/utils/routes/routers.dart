import 'package:fish_redux/fish_redux.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_server_client/models/page_component.dart';
import 'package:flutter_server_client/routes/chat_page/page.dart';
import 'package:flutter_server_client/routes/chat_page/state.dart';
import 'package:flutter_server_client/routes/login_page/page.dart';
import 'package:flutter_server_client/routes/photo_view_page/page.dart';
import 'package:flutter_server_client/routes/session_page/page.dart';
import '404.dart';

class Routes {
  //登录页面
  static String loginPage = "/loginPage";
  //最近会话页面
  static String sessionPage = "/sessionPage";
  //聊天页面
  static String chatPage = "/chatPage";
  //图片预览界面
  static String  photoViewPage = "/photoViewPage";

  static List<dynamic> listRoutes = [];

  static void configureRoutes(Router router) {
    /// 指定路由跳转错误返回页
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
          return WidgetNotFound();
        });

    listRoutes
        .add(PageComponent(pageName: Routes.loginPage, page: LoginPage()));
    listRoutes
        .add(PageComponent(pageName: Routes.sessionPage, page: SessionPage()));
    router.define(Routes.chatPage,
        handler: Handler(handlerFunc: (_, params) {
          return ChatPage().buildPage(
              ChatPageData(sessionId: params['sessionId'].first, nickName: params['nickName'].first));
        }));
    router.define(Routes.photoViewPage,
        handler: Handler(handlerFunc: (_, params) {
          return PhotoViewPage().buildPage(params['image'].first.toString());
        }));


    ///添加公共的方法
    listRoutes.forEach((dynamic route) {
//      route.page
//        ..enhancer.append(
//          /// View AOP
//          viewMiddleware: <ViewMiddleware<dynamic>>[
//            safetyView<dynamic>(),
//          ],
//
//          /// Adapter AOP
//          adapterMiddleware: <AdapterMiddleware<dynamic>>[
//            safetyAdapter<dynamic>()
//          ],
//
//          /// Effect AOP
//          effectMiddleware: <EffectMiddleware<dynamic>>[
//            _pageAnalyticsMiddleware<dynamic>(),
//          ],
//
//          /// Store AOP
//          middleware: <Middleware<dynamic>>[
//            logMiddleware<dynamic>(tag: route.page.runtimeType.toString()),
//          ],
//        );
      router.define(route.pageName,
          handler: Handler(
              handlerFunc:
                  (BuildContext context, Map<String, List<String>> params) =>
                  route.page.buildPage(null)));
    });
  }
}
/// 简单的 Effect AOP
/// 只针对页面的生命周期进行打印
EffectMiddleware<T> _pageAnalyticsMiddleware<T>({String tag = 'redux'}) {
  return (AbstractLogic<dynamic> logic, Store<T> store) {
    return (Effect<dynamic> effect) {
      return (Action action, Context<dynamic> ctx) {
        if (logic is Page<dynamic, dynamic> && action.type is Lifecycle) {
          print('${logic.runtimeType} ${action.type.toString()} ');
        }
        return effect?.call(action, ctx);
      };
    };
  };
}
