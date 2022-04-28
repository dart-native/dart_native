package com.dartnative.dart_native;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dartnative.dart_native.annotation.InterfaceEntry;
import com.dartnative.dart_native.annotation.InterfaceMethod;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class InterfaceMessenger {
    private volatile static InterfaceMessenger registry;

    private final Map<String, Object> mInterfaceMap = new HashMap<>();
    private final HashMap<String, String> mMethodSigMap = new HashMap<>();

    @NonNull
    private final Map<Integer, DartNativeInterface.DartNativeResult> pendingReplies = new HashMap<>();
    private int nextReplyId = 1;

    public static InterfaceMessenger getInstance() {
        if (registry == null) {
            synchronized (InterfaceMessenger.class) {
                if (registry == null) {
                    registry = new InterfaceMessenger();
                }
            }
        }
        return registry;
    }

    public void registerInterface(@NonNull Object module) {
        InterfaceEntry interfaceEntry = module.getClass().getAnnotation(InterfaceEntry.class);
        if (interfaceEntry == null || interfaceEntry.name().isEmpty()) {
            return;
        }
        mInterfaceMap.put(interfaceEntry.name(), module);
    }

    public void sendMessage(String interfaceName, String method, Object[] arguments, String[] argumentTypes,
                            int argumentCount, @Nullable DartNativeInterface.DartNativeResult result) {
        int replyId = nextReplyId++;
        if (result != null) {
            pendingReplies.put(replyId, result);
        } else {
            replyId = -1;
        }
        nativeInvokeMethod(interfaceName, method, arguments, argumentTypes, argumentCount, replyId);
    }

    @Nullable
    public Object getInterface(String interfaceName) {
        return mInterfaceMap.get(interfaceName);
    }

    @Nullable
    public String getMethodsSignature(String interfaceName) {
        Object obj = mInterfaceMap.get(interfaceName);
        if (obj == null) {
            return null;
        }
        Class clazz = obj.getClass();
        Method[] methods = clazz.getMethods();
        if (methods == null || methods.length == 0) {
            return null;
        }

        if (mMethodSigMap.containsKey(interfaceName)) {
            return mMethodSigMap.get(interfaceName);
        }

        HashMap<String, String> sigMap = new HashMap<>();
        for (Method method : methods) {
            InterfaceMethod interfaceMethod = method.getAnnotation(InterfaceMethod.class);
            if (interfaceMethod == null) {
                continue;
            }
            String sig = MethodUtils.buildSignature(method);
            String interfaceMethodName = interfaceMethod.name();
            if (interfaceMethodName == null || interfaceMethodName.isEmpty()) {
                interfaceMethodName = method.getName();
            }
            sigMap.put(interfaceMethodName, sig);
        }
        // mMethodSigMap value format like:
        // {buildSignature=buildSignature:Ljava/lang/String;'Ljava/lang/reflect/Method;}
        // It will decode in dart side.
        mMethodSigMap.put(interfaceName, sigMap.toString());
        return sigMap.toString();
    }

    void handleInterfaceResponse(int replyId, @Nullable Object object, @Nullable String errorMessage) {
        DartNativeInterface.DartNativeResult result = pendingReplies.remove(replyId);
        if (result == null) {
            return;
        }

        if (errorMessage != null) {
            result.error(errorMessage);
            return;
        }

        result.onResult(object);
    }

    private native void nativeInvokeMethod(String interfaceName, String method, Object[] arguments, String[] argumentTypes,
                                           int argumentCount, int replyId);
}
