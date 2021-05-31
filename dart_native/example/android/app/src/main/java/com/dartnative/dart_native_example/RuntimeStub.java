package com.dartnative.dart_native_example;

import android.os.Handler;
import android.os.Looper;
import io.flutter.Log;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class RuntimeStub {
    private final String TAG = "dart_java";

    public int getInt(int i) {
        return 100;
    }

    public double getDouble(double b) {
        Log.d(TAG, "getDouble : " + b);
        return 100.23;
    }

    public byte getByte(byte b) {
        Log.d(TAG, "getByte : " + b);
        return 2;
    }

    public float getFloat(float f) {
        Log.d(TAG, "getFloat : " + f);
        return 9.8f;
    }

    public char getChar(char c) {
        Log.d(TAG, "getChar : " + c);
        return 'b';
    }

    public short getShort(short c) {
        Log.d(TAG, "getShort : " + c);
        return 1;
    }

    public long getLong(long l) {
        Log.d(TAG, "getLong : " + l);
        return 1000L;
    }

    public boolean getBool(boolean b) {
        Log.d(TAG, "getBool : " + b);
        return false;
    }

    public String getString(String s) {
    //    Log.d(TAG, "getString : " + s);
       return "This is a long string: sdlfdksjflksndhiofuu2893873(*（%￥#@）*&……￥撒肥料开发时傅雷家书那份会计师东方丽景三等奖";
    }

    public int add(int a, int b) {
        Log.d(TAG, "add :" + a + " + " + b);
        return a + b;
    }

    public void log(String tag, String message) {
        Log.d(tag, message);
    }

    public boolean complexCall(String s, int i, char c, double d, float f, byte b, short sh, long l, boolean bool) {
        Log.d(TAG, "tag :" + s + " + " + i + " + " + c + " + " + d + " + " + f + " + " + b + " + " + sh + " + " + l + " + " + bool);
        return true;
    }

    public Entity createEntity() {
        return new Entity();
    }

    public int getTime(Entity entity) {
        return entity.getCurrentTime();
    }

    public void setDelegateListener(SampleDelegate delegate) {
        Log.d(TAG, "invoke setDelegateListener");
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            boolean isSuccess = delegate.callbackComplex(20, 100.0, "wwawawawawa");
            Log.d(TAG, "callback result " + isSuccess);
        }, 2000);
    }

    public Integer getInteger() {
        return new Integer(10);
    }

    public List<Integer> getList(List<Integer> list) {
        for (int i = 0; i < list.size(); i++) {
            Log.d(TAG, "element is " + list.get(i));
        }
        List<Integer> returnList = new ArrayList<>();
        returnList.add(7);
        returnList.add(8);
        return returnList;
    }

    public List<Byte> getByteList(List<Byte> list) {
        for (int i = 0; i < list.size(); i++) {
            Log.d(TAG, "element is " + list.get(i));
        }
        List<Byte> returnList = new ArrayList<>();
        returnList.add((byte) 1);
        returnList.add((byte) 100);
        return returnList;
    }

    public List<Float> getFloatList(List<Float> list) {
        for (int i = 0; i < list.size(); i++) {
            Log.d(TAG, "element is " + list.get(i));
        }
        List<Float> returnList = new ArrayList<>();
        returnList.add(1.2f);
        returnList.add(100.345f);
        return returnList;
    }

    public List<String> getStringList(List<String> list) {
        for (int i = 0; i < list.size(); i++) {
            Log.d(TAG, "element is " + list.get(i));
        }
        List<String> returnList = new ArrayList<>();
        returnList.add("1.2f");
        returnList.add("100.345f");
        return returnList;
    }

    public List<List<Integer>> getCycleList(List<List<Integer>> list) {
        for (int i = 0; i < list.size(); i++) {
            for (int j = 0; j < list.get(i).size(); j++) {
                Log.d(TAG, "element is " + list.get(i).get(j));
            }
        }
        ArrayList<Integer> newList1 = new ArrayList<>();
        newList1.add(65);
        newList1.add(67);

        ArrayList<Integer> newList2 = new ArrayList<>();
        newList2.add(89);
        newList2.add(98);

        List<List<Integer>> returnList = new ArrayList<>();
        returnList.add(newList1);
        returnList.add(newList2);
        return returnList;
    }

    public byte[] getByteArray(byte[] bytes) {
        for (int i = 0; i < bytes.length; i++) {
            Log.d(TAG, "element is " + bytes[i]);
        }
        return new byte[]{1, 2, 10};
    }

    public Set<Integer> getIntSet(HashSet<Integer> set) {
        for (Integer element : set) {
            Log.d(TAG, "Set element is " + element);
        }
        Set<Integer> backSet = new HashSet<>();
        backSet.add(600);
        backSet.add(700);
        backSet.add(800);
        backSet.add(900);
        return backSet;
    }

    public Set<Float> getFloatSet(HashSet<Float> set) {
        for (Float element : set) {
            Log.d(TAG, "Set element is " + element);
        }
        Set<Float> backSet = new HashSet<>();
        backSet.add(60.0f);
        backSet.add(70.0f);
        return backSet;
    }

    public Map getMap(HashMap<String, Integer> map) {
        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            Log.d(TAG, "Key = " + entry.getKey() + ", Value = " + entry.getValue());
        }
        HashMap<String, Float> backMap = new HashMap<>();
        backMap.put("1", 1.0f);
        backMap.put("2", 2.0f);
        return backMap;
    }
}
