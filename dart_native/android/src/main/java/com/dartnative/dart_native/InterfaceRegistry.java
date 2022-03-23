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
    private final Map<String, Object> mInterfaceMap = new HashMap<>();
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
                    mInterfaceMap.put(name, module);
                }
                return;
            }

            if (interfaceEntry.name().isEmpty()) {
                return;
            }
            mInterfaceMap.put(interfaceEntry.name(), module);
        }
    }

    @Nullable
    public Object getInterface(String interfaceName) {
        Object dnInterface;
        synchronized (registryLock) {
            dnInterface = mInterfaceMap.get(interfaceName);
        }
        return dnInterface;
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

        if (mMethodSigMap.containsKey(clazz)) {
            return mMethodSigMap.get(clazz);
        }

        HashMap<String, String> sigMap = new HashMap<>();
        for (Method method : methods) {
            InterfaceMethod interfaceMethod = method.getAnnotation(InterfaceMethod.class);
            if (interfaceMethod == null) {
                continue;
            }
            String sig = MethodUtils.buildSignature(method);
            String methodName = interfaceMethod.name();
            if (methodName == null || methodName.isEmpty()) {
                methodName = method.getName();
            }
            sigMap.put(methodName, sig);
        }
        mMethodSigMap.put(clazz, sigMap.toString());
        return sigMap.toString();
    }
}
