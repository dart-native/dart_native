package com.dartnative.dart_native;

import android.text.TextUtils;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
      return targetClass.getDeclaredMethod(method, double.class);
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

  private static Map<String, Class> basicClassMap = new HashMap<String, Class>(){{
    put("I", int.class);
  }};

  public static String getMethodReturnType(Class cls, String methodName, String[] argTypes) {
    try {
      Class[] parameterTypes = new Class[argTypes.length];
      for (int index = 0; index < argTypes.length; index++) {
        String type = argTypes[index];
        if (basicClassMap.containsKey(type)) {
          parameterTypes[index] = basicClassMap.get(type);
          continue;
        }

        parameterTypes[index] = Class.forName(type);
      }
      Method findMethod =  cls.getMethod(methodName, parameterTypes);
      String type = findMethod.getReturnType().toString();
      Log.d("HUIZZ", "type info " + type);
      return type;
    } catch (NoSuchMethodException ignored) {

    } catch (ClassNotFoundException ignored) {

    }
    return null;
  }
}
