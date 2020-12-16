package com.dartnative.dart_native_example;

import android.os.Handler;
import android.os.Looper;
import io.flutter.Log;

public class RuntimeStub {
  private final String TAG = "dart_java";

  public RuntimeStub() {
    long start = System.nanoTime();
    getDouble(100.23);
    long use = System.nanoTime() - start;
    System.out.println("getDouble in java , cost: " + use / 1000);
  }

  public int getInt(int i){
    return 100;
  }

  public double getDouble(double b) {
    return 100.23;
  }

  public byte getByte(byte b) {
    return 2;
  }

  public float getFloat(float f) {
    return 9.8f;
  }

  public char getChar(char c) {
    return 'b';
  }

  public short getShort(short c) {
    return 1;
  }

  public long getLong(long l) {
    return 1000L;
  }

  public boolean getBool(boolean b) {
    return false;
  }

  public String getString(String s) {
    return "test success";
  }

  public int add(int a, int b) {
    return a + b;
  }

  public void log(String tag, String message) {
    Log.d(tag, message);
  }

  public boolean complexCall(String s, int i, char c, double d, float f, byte b, short sh, long l, boolean bool) {
    return true;
  }

  public Entity createEntity() {
    return new Entity();
  }

  public int getTime(Entity entity) {
    return entity.getCurrentTime();
  }

  public void setDelegateListener(SampleDelegate delegate) {
    Log.d(TAG, "invoke setDelegateListener");
    new Handler(Looper.getMainLooper()).postDelayed(() -> {
      Log.d(TAG, "time to callback");
      delegate.callbackComplex(20, 100.0, "wwawawawawa");
    }, 2000);
  }
}
