package com.dartnative.dart_native;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.dartnative.dart_native.annotation.InterfaceEntry;
import com.dartnative.dart_native.annotation.InterfaceMethod;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class InterfaceRegistry {
    private volatile static InterfaceRegistry registry;
    private final Map<String, Object> mModuleMap = new HashMap<>();
    private final HashMap<Class, String> mMethodSigMap = new HashMap<>();
    private final Object registryLock = new Object();

    public static InterfaceRegistry getInstance() {
        if (registry == null) {
            synchronized (InterfaceRegistry.class) {
                if (registry == null) {
                    registry = new InterfaceRegistry();
                }
            }
        }
        return registry;
    }

    public void registerInterface(@NonNull Object module) {
        InterfaceEntry interfaceEntry = module.getClass().getAnnotation(InterfaceEntry.class);
        if (interfaceEntry == null) {
            return;
        }
        synchronized (registryLock) {
            if (interfaceEntry.names().length > 0) {
                for (String name : interfaceEntry.names()) {
                    mModuleMap.put(name, module);
                }
                return;
            }

            if (interfaceEntry.name().isEmpty()) {
                return;
            }
            mModuleMap.put(interfaceEntry.name(), module);
        }
    }

    @Nullable
    public Object getInterface(String channelName) {
        Object channel = null;
        synchronized (registryLock) {
            channel = mModuleMap.get(channelName);
        }
        return channel;
    }

    @Nullable
    public String getMethodsSignature(Object obj) {
        if (obj == null) {
            return null;
        }

        String ret;
        Class clazz = obj.getClass();
        if (mMethodSigMap.containsKey(clazz)) {
            ret = mMethodSigMap.get(clazz);
            return ret;
        }

        Method[] methods = clazz.getMethods();
        if (methods == null || methods.length == 0) {
            return null;
        }
        HashMap<String, String> resultMap = new HashMap<>();
        for (int i = 0; i < methods.length; i++) {
            InterfaceMethod method = methods[i].getAnnotation(InterfaceMethod.class);
            if (method == null) {
                continue;
            }
            String sig = MethodUtils.buildSignature(methods[i]);
            String methodName = method.name();
            if (methodName == null || methodName.isEmpty()) {
                methodName = methods[i].getName();
            }
            resultMap.put(methodName, sig);
        }
        if (resultMap.size() == 0) {
            ret = null;
        } else {
            ret = resultMap.toString();
        }
        mMethodSigMap.put(clazz, ret);
        return ret;
    }

}
