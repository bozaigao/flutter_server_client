package com.guigug.server;

import androidx.annotation.NonNull;
import com.guigug.server.FlutterSound.FlutterSoundPlugin;
import com.guigug.server.NativeUtil.NativeUtilPlugin;
import com.guigug.server.NimPlugin.FlutterNimPlugin;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    //网易云信聊天插件
    FlutterNimPlugin.registerWith(flutterEngine,this);
    //原生模块插件封装
    NativeUtilPlugin.registerWith(flutterEngine,this);
    //录制于播放插件封装
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    FlutterSoundPlugin.registerWith(shimPluginRegistry.registrarFor("www.guigug.com/flutter_sound"));
  }
}
