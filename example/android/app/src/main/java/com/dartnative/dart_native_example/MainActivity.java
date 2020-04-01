package com.dartnative.dart_native_example;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

import java.lang.reflect.Method;
import java.util.NoSuchElementException;

public class MainActivity extends FlutterActivity {
  public static final String TAG = "dart_java";

  static{
    System.loadLibrary("test_lib");
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

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

  public static String getMethodType(String methodName) {
    Method[] clsMethod = MainActivity.class.getDeclaredMethods();
    Method findMethod = null;
    for (Method method : clsMethod) {
      if (TextUtils.equals(method.getName(), methodName)) {
        findMethod = method;
        break;
      }
    }
    if (findMethod == null) {
      throw new NoSuchElementException(methodName);
    }
    return findMethod.getGenericReturnType().toString();

//    try {
//      Method clsMethod = MainActivity.class.getDeclaredMethod(methodName);
//      return clsMethod.getGenericReturnType().toString();
//    } catch (NoSuchMethodException e) {
//      throw new NoSuchElementException(e.getMessage());
//    }
  }

  public static Method getMethod(String method) {
    try {
      return MainActivity.class.getDeclaredMethod(method);
    } catch (NoSuchMethodException e) {
      throw new NoSuchElementException(e.getMessage());
    }
  }

  public static String[] getMethodParams(String methodName) {
    Method[] clsMethod = MainActivity.class.getDeclaredMethods();
    Method findMethod = null;
    for (Method method : clsMethod) {
      if (TextUtils.equals(method.getName(), methodName)) {
        findMethod = method;
        break;
      }
    }
    if (findMethod == null) {
      throw new NoSuchElementException(methodName);
    }
    Class[] typeClasses = findMethod.getParameterTypes();
    int count = 0;
    String[] methodTypes = new String[typeClasses.length];
    for (Class type : typeClasses) {
      methodTypes[count] = type.getCanonicalName();
      count++;
    }
    return methodTypes;
  }
}
