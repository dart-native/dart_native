package com.dartnative.dart_native_example;

import androidx.annotation.NonNull;
import io.flutter.Log;

public class RuntimeStub {
  private final String TAG = "dart_java";

  public int getInt(int i){
    Log.d(TAG, "getInt : " + i);
    return 100;
  }

  public double getDouble(double b) {
    Log.d(TAG, "getDouble : " + b);
    return 100.23;
  }

  public byte getByte(byte b) {
    Log.d(TAG, "getByte : " + b);
    return 2;
  }

  public float getFloat(float f) {
    Log.d(TAG, "getFloat : " + f);
    return 9.8f;
  }

  public char getChar(char c) {
    Log.d(TAG, "getChar : " + c);
    return 'b';
  }

  public short getShort(short c) {
    Log.d(TAG, "getShort : " + c);
    return 1;
  }

  public long getLong(long l) {
    Log.d(TAG, "getLong : " + l);
    return 1000L;
  }

  public boolean getBool(boolean b) {
    Log.d(TAG, "getBool : " + b);
    return false;
  }
}
