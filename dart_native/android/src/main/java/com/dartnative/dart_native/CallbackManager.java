package com.dartnative.dart_native;

import android.util.Log;

import java.lang.reflect.Proxy;
import java.util.HashMap;

import androidx.annotation.Nullable;

/**
 * Created by huizzzhou on 2020/11/11.
 */
public class CallbackManager {
    private static final String TAG = "CallbackManager";
    private static CallbackManager sCallbackManager;

    private CallbackInvocationHandler mCallbackHandler = new CallbackInvocationHandler();
    private HashMap<Integer, Long> mObjectMap = new HashMap<>();

    static CallbackManager getInstance() {
        if (sCallbackManager == null) {
            synchronized (CallbackManager.class) {
                if (sCallbackManager == null) {
                    sCallbackManager = new CallbackManager();
                }
            }
        }
        return sCallbackManager;
    }

    @Nullable
    public static Object registerCallback(long dartAddr, String clsName) {
        try {
            Class<?> clz = Class.forName(clsName.replace("/", "."));
            Object proxyObject = Proxy.newProxyInstance(
                    clz.getClassLoader(),
                    new Class[] { clz },
                    getInstance().mCallbackHandler);

            getInstance().mObjectMap.put(System.identityHashCode(proxyObject), dartAddr);
            return proxyObject;
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
        return null;
    }

    long getRegisterDartAddr(Object proxyObject) {
        if (proxyObject == null) {
            return 0L;
        }

        Long dartAddress = getInstance().mObjectMap.get(System.identityHashCode(proxyObject));
        return dartAddress == null ? 0L : dartAddress;
    }

}
