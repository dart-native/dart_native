package com.dartnative.dart_native;

import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.BinaryMessenger;

/** DartNativePlugin */
public class DartNativePlugin implements FlutterPlugin, MethodCallHandler {

  public static final String TAG = "DartNativePlugin";

  public static String sSoPath = "libdart_native.so";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
    final MethodChannel channel = new MethodChannel(messenger, "dart_native");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "dart_native");
    channel.setMethodCallHandler(new DartNativePlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getDylibPath")) {
      result.success(sSoPath);
    } else {
      result.notImplemented();
    }
  }

  public static void setSoPath(String soPath) {
    Log.d(TAG, "so path : " + soPath);
    if (!TextUtils.isEmpty(soPath)) {
      sSoPath = soPath;
      System.load(soPath);
      return;
    }
    System.loadLibrary("dart_native");
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
