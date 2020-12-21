package com.dartnative.dart_native_example;

import com.dartnative.dart_native.DartNativePlugin;

import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  public static final String TAG = "dart_java";

  static {
    DartNativePlugin.setSoPath("");
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
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
