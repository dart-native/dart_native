package com.dartnative.dart_native_example;

import androidx.annotation.NonNull;
import io.flutter.Log;

public class RuntimeStub {
  public static final String TAG = "dart_java";

  public static int getInt(int i){
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
