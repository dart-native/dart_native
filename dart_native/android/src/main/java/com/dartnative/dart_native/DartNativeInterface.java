package com.dartnative.dart_native;

import androidx.annotation.Nullable;

import com.dartnative.dart_native.annotation.InterfaceEntry;

public class DartNativeInterface {

    public interface DartNativeResult {
        void onResult(@Nullable Object result);

        void error(@Nullable String errorMessage);
    }

    public void invokeMethod(String method, Object[] arguments) {
        invokeMethod(method, arguments, null);
    }

    public void invokeMethod(String method, Object[] arguments, @Nullable DartNativeResult result) {
        InterfaceEntry interfaceEntry = getClass().getAnnotation(InterfaceEntry.class);
        if (interfaceEntry == null || interfaceEntry.name().isEmpty()) {
            if (result != null) {
                result.error("Interface is not register!");
            }
            return;
        }

        if (method == null || method.isEmpty()) {
            if (result != null) {
                result.error("Method name is empty!");
            }
            return;
        }

        int argumentCount = arguments == null ? 0 : arguments.length;
        String[] argumentTypes = new String[argumentCount];
        for (int i = 0; i < argumentCount; i++) {
            argumentTypes[i] = arguments[i] != null ? arguments[i].getClass().getName() : null;
        }

        InterfaceRegistry.getInstance().sendMessage(interfaceEntry.name(), method, arguments, argumentTypes, argumentCount, result);
    }
}
