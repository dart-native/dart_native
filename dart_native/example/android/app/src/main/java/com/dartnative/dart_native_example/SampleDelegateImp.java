package com.dartnative.dart_native_example;

import android.util.Log;

/**
 * Created by huizzzhou on 2020/11/10.
 */
public class SampleDelegateImp implements SampleDelegate {
    private final static String TAG = "SampleDelegateImp";

    @Override
    public void callbackInt(int i) {
        Log.d(TAG, "callback int");
    }
}
