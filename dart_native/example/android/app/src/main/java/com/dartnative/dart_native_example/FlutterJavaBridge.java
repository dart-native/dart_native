package com.dartnative.dart_native_example;

import android.util.Log;

import java.lang.reflect.Method;

public class FlutterJavaBridge {
    public static final String TAG = "FlutterJavaBridge";
    public static final JavaObjectManager sJavaObjectManager = JavaObjectManager.getInstance();
    public static ParamsDecoder sParamsDecoder = ParamsDecoder.getInstance();

    public static int newObject(String className, byte[] paramsBuffer){
        Log.i(TAG, "west java invoke newObject className: " + className);
        return sJavaObjectManager.newObject(className, paramsBuffer);
    }


    public static byte[] invoke(int objectHashCode, String methodName, byte[] paramsBuffer) {
        Object[] params = sParamsDecoder.decode(paramsBuffer);

        Object object = sJavaObjectManager.getObject(objectHashCode);
        if(null == object){
            Log.e(TAG, "get object error, hashCode:" + objectHashCode);
        }

        try {
            Method method = sParamsDecoder.getSuteableMethod(object.getClass(), methodName, params);
            Object result = method.invoke(object, params);
            return sParamsDecoder.encode(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new byte[0];
    }
}
