package com.dartnative.dart_native;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Created by huizzzhou on 2020/11/11.
 */
public class CallbackInvocationHandler implements InvocationHandler {
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

    AtomicBoolean done = new AtomicBoolean(false);

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        boolean isDartFunctionHandler = proxy instanceof FunctionHandler;
        // For auto release memory, invoke only once.
        if (isDartFunctionHandler && done.getAndSet(true)) {
            throw new IllegalStateException("Invoke already submitted.");
        }
        args = (isDartFunctionHandler && args != null) ? (Object[]) args[0] : args;
        int argumentLength = args == null ? 0 : args.length;
        String[] paramsType = new String[argumentLength];
        for (int i = 0; i < argumentLength; i++) {
            paramsType[i] = args[i] != null ? args[i].getClass().getName() : null;
        }

        String funName = method.getName();
        String returnType = method.getReturnType().getName();
        returnType = sBasicTypeConvert.get(returnType) == null ? returnType : sBasicTypeConvert.get(returnType);
        long dartObjectAddress = CallbackManager.getInstance().getRegisterDartAddr(proxy);
        if (isDartFunctionHandler) {
            CallbackManager.unRegisterCallback(proxy);
        }

        return hookCallback(dartObjectAddress, funName, argumentLength, paramsType, args, returnType, isDartFunctionHandler);
    }

    private native Object hookCallback(long dartObjectAddress, String funName, int argCount, String[] argTypes, Object[] args, String returnType, boolean isDartFunctionHandler);
}
