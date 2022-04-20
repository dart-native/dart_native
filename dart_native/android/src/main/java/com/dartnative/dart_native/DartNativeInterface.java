package com.dartnative.dart_native;

import com.dartnative.dart_native.annotation.InterfaceEntry;

public class DartNativeInterface {

    public Object invokeMethod(String method, Object[] arguments) {
        InterfaceEntry interfaceEntry = getClass().getAnnotation(InterfaceEntry.class);
        if (interfaceEntry == null || interfaceEntry.name().isEmpty()) {
            return null;
        }

        if (method == null || method.isEmpty()) {
            return null;
        }

        int argumentCount = arguments == null ? 0 : arguments.length;
        String[] argumentTypes = new String[argumentCount];
        for (int i = 0; i < argumentCount; i++) {
            argumentTypes[i] = arguments[i] != null ? arguments[i].getClass().getName() : null;
        }

        return nativeInvokeMethod(interfaceEntry.name(), method, arguments, argumentTypes, argumentCount);
    }

    private native Object nativeInvokeMethod(String interfaceName, String method, Object[] arguments, String[] argumentTypes, int argumentCount);
}
