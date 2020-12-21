package com.dartnative.dart_native;

import android.util.Log;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.util.HashMap;

/**
 * Created by huizzzhou on 2020/11/11.
 */
public class CallbackInvocationHandler implements InvocationHandler {
    private static final String TAG = "CallbackHandler";

    private static HashMap<Class<?>, String> sTypeConvert = new HashMap<Class<?>, String>() {{
        put(int.class, "I");
        put(float.class, "F");
        put(double.class, "D");
        put(boolean.class, "Z");
        put(String.class, "Ljava/lang/String;");
    }};

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Log.d(TAG, "invoke method: " + method.getName());
        Class<?>[] paramTypes = method.getParameterTypes();
        String[] params = new String[paramTypes.length];
        for (int i = 0; i < paramTypes.length; i++) {
            params[i] = sTypeConvert.get(paramTypes[i]);
        }
        String funName = method.getName();
        String returnType = sTypeConvert.get(method.getReturnType());
        long dartObjectAddr = CallbackManager.getInstance().getRegisterDartAddr(proxy);
        return hookCallback(dartObjectAddr, funName, paramTypes.length, params, args, returnType);
    }

    static native Object hookCallback(long dartObjectAddr, String funName, int argCount, String[] argTypes, Object[] args, String returnType);
}
