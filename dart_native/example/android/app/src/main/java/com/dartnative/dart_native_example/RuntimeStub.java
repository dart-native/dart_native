package com.dartnative.dart_native_example;

import androidx.annotation.NonNull;
import io.flutter.Log;

public class RuntimeStub {
  private final String TAG = "dart_java";

  public int getInt(int i){
    Log.d(TAG, "west success invoke getInt : " + i);
    return i;
  }

  public double getDouble(double b) {
    Log.d(TAG, "west success invoke getDouble : " + b);
    return 100.23;
  }

  public byte getByte(byte b) {
    Log.d(TAG, "west success invoke getByte : " + b);
    return 2;
  }

  public float getFloat(float f) {
    Log.d(TAG, "west success invoke getFloat : " + f);
    return 9.8f;
  }

  public char getChar(char c) {
    Log.d(TAG, "west success invoke getChar : " + c);
    return 'b';
  }

  public short getShort(short c) {
    Log.d(TAG, "west success invoke getShort : " + c);
    return 1;
  }

  public long getLong(long l) {
    Log.d(TAG, "west success invoke getLong : " + l);
    return 1000L;
  }

  public boolean getBool(boolean b) {
    Log.d(TAG, "west success invoke getBool : " + b);
    return false;
  }

  public String getString(String s) {
    Log.d(TAG, "west success invoke getString : " + s);
    return "test success";
  }

  public int add(int a, int b) {
    Log.d(TAG, "west success invoke add :" + a + " + " + b);
    return a + b;
  }

  public void log(String tag, String message) {
    Log.d(tag, message);
  }

  public boolean complexCall(String s, int i, char c, double d, float f, byte b, short sh, long l, boolean bool) {
    Log.d(TAG, "west success invoke tag :" + s + " + " + i + " + " + c + " + " + d + " + " + f + " + " + b + " + " + sh + " + " + l + " + " + bool);
    return true;
  }
}
