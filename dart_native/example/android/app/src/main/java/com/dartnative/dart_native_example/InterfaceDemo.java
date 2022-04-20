package com.dartnative.dart_native_example;

import android.util.Log;

import com.dartnative.dart_native.DartNativeInterface;
import com.dartnative.dart_native.annotation.InterfaceEntry;
import com.dartnative.dart_native.annotation.InterfaceMethod;

@InterfaceEntry(name = "MyFirstInterface")
public class InterfaceDemo extends DartNativeInterface {

    @InterfaceMethod(name = "hello")
    public String hello(String str) {
        Log.d("InterfaceDemo", "str " + str);
        invokeMethod("totalCost", new Object[]{10.0, 10});
        return "hello " + str;
    }

    @InterfaceMethod(name = "sum")
    public int sum(int a, int b) {
        return a + b;
    }

    @InterfaceMethod(name = "log")
    public void log(String str) {
    }
}
