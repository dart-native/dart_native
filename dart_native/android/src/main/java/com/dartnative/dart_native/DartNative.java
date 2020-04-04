package com.dartnative.dart_native;

import android.text.TextUtils;

import java.lang.reflect.Method;
import java.util.NoSuchElementException;

public class DartNative {

  public static final String TAG = "dart_java";
  private static Class targetClass = DartNative.class;

  public static void setTargetClass(Class target) {
    targetClass = target;
  }

  public static String getMethodType(String methodName) {
    Method[] clsMethod = targetClass.getDeclaredMethods();
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
//      Method clsMethod = DartNative.class.getDeclaredMethod(methodName);
//      return clsMethod.getGenericReturnType().toString();
//    } catch (NoSuchMethodException e) {
//      throw new NoSuchElementException(e.getMessage());
//    }
  }

  public static Method getMethod(String method) {
    try {
      return targetClass.getDeclaredMethod(method);
    } catch (NoSuchMethodException e) {
      throw new NoSuchElementException(e.getMessage());
    }
  }

  public static String[] getMethodParams(String methodName) {
    Method[] clsMethod = targetClass.getDeclaredMethods();
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
