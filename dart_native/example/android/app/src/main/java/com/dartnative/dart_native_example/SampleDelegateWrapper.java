package com.dartnative.dart_native_example;

import android.util.Log;

import java.util.Map;

/**
 * Created by huizzzhou on 2020/11/10.
 */
public class SampleDelegateWrapper implements SampleDelegate {
    private final static String TAG = "SampleDelegateWrapper";

    @Override
    public void callbackInt(int i) {
        Log.d(TAG, " call back result " + i);
    }

    public void registerCallback() {

    }

    public void getCallback() {

    }
}
