package com.dartnative.dart_native_example;

import com.dartnative.dart_native.DartNativePlugin;

import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  public static final String TAG = "dart_java";
  private final String CHANNEL_NAME = "dart_native.example";

  static {
    DartNativePlugin.setSoPath("");
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME).setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if ("channelInt".equals(call.method)) {
          result.success(100);
        } else if ("channelString".equals(call.method)) {
          result.success("test success");
        } else {
          result.notImplemented();
        }
      }
    });
  }

  public int getInt(int i){
    Log.d(TAG, "getInt : " + i);
    return 100;
  }

  public static double getDouble(double b) {
    Log.d(TAG, "getDouble : " + b);
    return 100.23;
  }

  public static byte getByte() {
    return 1;
  }

  public static float getFloat(float f) {
    Log.d(TAG, "getFloat : " + f);
    return 9.8f;
  }

  public static char getChar(char c) {
    Log.d(TAG, "getChar : " + c);
    return 'b';
  }

  public static short getShort() {
    return 1;
  }

  public static long getLong() {
    return 1;
  }

  public static boolean getBool(boolean b) {
    Log.d(TAG, "getBool : " + b);
    return false;
  }
}
