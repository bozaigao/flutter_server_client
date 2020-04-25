package com.guigug.server.NativeUtil;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * @author 何晏波
 * @filename NativeUtilPlugin.java
 * @QQ 1054539528
 * @date 2020-04-14
 * @Description: 原生模块插件封装
 */
public class NativeUtilPlugin implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL = "www.guigug.com/native_util_plugin";
    static MethodChannel channel;
    public static Context context;

    public static void registerWith(FlutterEngine flutterEngine, Context context) {
        NativeUtilPlugin.context = context;
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        NativeUtilPlugin instance = new NativeUtilPlugin();
        //setMethodCallHandler在此通道上接收方法调用的回调
        channel.setMethodCallHandler(instance);
    }


    private void checkNetworkAvailable(MethodCall call, MethodChannel.Result result) {
        ConnectivityManager manager = (ConnectivityManager) NativeUtilPlugin.context
                .getApplicationContext().getSystemService(
                        Context.CONNECTIVITY_SERVICE);

        if (manager == null) {
            result.success(false);
        } else {
            NetworkInfo networkinfo = manager.getActiveNetworkInfo();
            if (networkinfo == null || !networkinfo.isAvailable()) {
                result.success(false);
            } else {
                result.success(true);
            }
        }
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        //接收来自flutter的指令encode
        if (call.method.equals("checkNetworkAvailable")) {
            //返回给flutter的参数
            checkNetworkAvailable(call, result);
        }
    }
}