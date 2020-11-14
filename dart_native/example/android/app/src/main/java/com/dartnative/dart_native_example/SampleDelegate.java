package com.dartnative.dart_native_example;

/**
 * Created by huizzzhou on 2020/11/10.
 */
public interface SampleDelegate {
    void callbackInt(String s1);
    void callbackString(String s);
    boolean callbackComplete(int i, float f, String s);
}
