package com.dartnative.dart_native;

import android.util.Log;

import java.lang.reflect.Proxy;
import java.util.HashMap;
import java.util.List;

/**
 * Created by huizzzhou on 2020/11/11.
 */
public class CallbackManager {
    private static final String TAG = "CallbackManager";
    private static CallbackManager sCallbackManager;

    private static CallbackInvocationHandler sCallbackHandler = new CallbackInvocationHandler();
    private HashMap<String, HashMap<String, List<Object>>> mMethodMap = new HashMap();

    public static CallbackManager getInstance() {
        if (sCallbackManager == null) {
            synchronized (CallbackManager.class) {
                if (sCallbackManager == null) {
                    sCallbackManager = new CallbackManager();
                }
            }
        }
        return sCallbackManager;
    }

    public static Object registerCallback(String clsName) {
        try {
            Class<?> clz = Class.forName(clsName.replace("/", "."));
            Log.d(TAG, clsName.replace("/", "."));
            return Proxy.newProxyInstance(clz.getClassLoader(), new Class[] { clz }, sCallbackHandler);
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
        return null;
    }

    public static native void hookCallback(Object o);
}
