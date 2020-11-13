package com.dartnative.dart_native;

import android.util.Log;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

/**
 * Created by huizzzhou on 2020/11/11.
 */
public class CallbackInvocationHandler implements InvocationHandler {
    private static final String TAG = "CallbackHandler";

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Log.d(TAG, "invoke method: " + method.getName());
        String funName = method.getName();
        long dartObjectAddr = CallbackManager.getInstance().getRegisterDartAddr(proxy);
        hookCallback(dartObjectAddr, funName, args);
        return proxy;
    }

    static native void hookCallback(long dartObjectAddr, String funName, Object[] args);
}
