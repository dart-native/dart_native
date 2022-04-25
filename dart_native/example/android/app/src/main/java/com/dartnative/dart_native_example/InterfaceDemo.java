package com.dartnative.dart_native_example;

import android.util.Log;

import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.Map;

import com.dartnative.dart_native.DartNativeInterface;
import com.dartnative.dart_native.annotation.InterfaceEntry;
import com.dartnative.dart_native.annotation.InterfaceMethod;

@InterfaceEntry(name = "MyFirstInterface")
public class InterfaceDemo extends DartNativeInterface {

    @InterfaceMethod(name = "hello")
    public String hello(String str) {
        Log.d("InterfaceDemo", "str " + str);
        invokeMethod("totalCost", new Object[]{10.0, 10, Arrays.asList("hello", "world")}, new DartNativeResult() {
            @Override
            public void onResult(@Nullable Object result) {
                if (result == null) {
                    Log.d("InterfaceDemo", "result is null");
                    return;
                }
                Map retMap = (Map) result;
                Log.d("InterfaceDemo", "map size " + retMap.size() + " " + retMap.toString());
            }

            @Override
            public void error(@Nullable String errorMessage) {
                Log.e("InterfaceDemo", "invokeMethod error " + errorMessage);
            }
        });
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
