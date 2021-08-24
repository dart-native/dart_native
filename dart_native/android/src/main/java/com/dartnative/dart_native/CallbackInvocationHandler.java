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

    private static final HashMap<String, String> sBasicTypeConvert = new HashMap<String, String>() {{
        put("int", "java.lang.Integer");
        put("float", "java.lang.Float");
        put("double", "java.lang.Double");
        put("boolean", "java.lang.Boolean");
        put("byte", "java.lang.Byte");
        put("short", "java.lang.Short");
        put("long", "java.lang.Long");
        put("char", "java.lang.Character");
    }};

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Log.d(TAG, "invoke method: " + method.getName());
        int argumentLength = args == null ? 0 : args.length;
        String[] paramsType = new String[argumentLength];
        for (int i = 0; i < argumentLength; i++) {
            paramsType[i] = args[i] != null ? args[i].getClass().getName() : null;
        }

        String funName = method.getName();
        String returnType = method.getReturnType().getName();
        returnType = sBasicTypeConvert.get(returnType) == null ? returnType : sBasicTypeConvert.get(returnType);
        long dartObjectAddress = CallbackManager.getInstance().getRegisterDartAddr(proxy);

        return hookCallback(dartObjectAddress, funName, argumentLength, paramsType, args, returnType);
    }

    static native Object hookCallback(long dartObjectAddress, String funName, int argCount, String[] argTypes, Object[] args, String returnType);
}
