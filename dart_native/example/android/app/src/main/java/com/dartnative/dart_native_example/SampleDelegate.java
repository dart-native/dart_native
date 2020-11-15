package com.dartnative.dart_native_example;

/**
 * Created by huizzzhou on 2020/11/10.
 */
public interface SampleDelegate {
    void callbackInt(int i);
    void callbackString(String s);
    void callbackFloat(float f);
    void callbackDouble(double d);
    void callbackComplex(int i, double d, String s);
}
