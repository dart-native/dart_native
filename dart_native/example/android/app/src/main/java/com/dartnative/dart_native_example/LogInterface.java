package com.dartnative.dart_native_example;

import android.util.Log;

import com.dartnative.dart_native.DartNativeInterface;
import com.dartnative.dart_native.annotation.InterfaceEntry;
import com.dartnative.dart_native.annotation.InterfaceMethod;

@InterfaceEntry(name = "logInterface")
public class LogInterface extends DartNativeInterface {
    private final static String TAG = "LogInterface";
    private int level = 0;

    @InterfaceMethod(name = "log")
    public void log(int level, String message) {
        Log.e(TAG, message);
    }

    @InterfaceMethod(name = "setLevel")
    public void setLevel(int level) {
        this.level = level;
    }
}
