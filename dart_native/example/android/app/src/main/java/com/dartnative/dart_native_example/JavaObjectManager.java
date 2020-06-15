package com.dartnative.dart_native_example;

import android.util.Log;

import java.lang.reflect.Constructor;
import java.util.HashMap;
import java.util.Map;

public class JavaObjectManager {
    public static final String TAG = "JavaObjectManager";

    Map<Integer, Object> mObjectCache = new HashMap<>();
    ParamsDecoder mParamsDecoder = ParamsDecoder.getInstance();

    public static JavaObjectManager sJavaObjectManager;
    public static synchronized JavaObjectManager getInstance(){
        if(null == sJavaObjectManager){
            sJavaObjectManager = new JavaObjectManager();
        }
        return sJavaObjectManager;
    }

    /**
     * 返回一个对应java object对象的一个int表示
     * @param className 类名
     * @param bytes 构造函数参数
     * @return 一个int表示的object, 0则表示构造函数失败
     */
    public int newObject(String className, byte[] bytes) {
        try {
            Object[] params = mParamsDecoder.decode(bytes);

            Class clazz = Class.forName(className);
            //TODO 这里考虑做缓存
            Constructor constructor = mParamsDecoder.getSuteableConstructor(clazz, params);
            if(null == constructor){
                Log.e(TAG, "can not find suteable constructor, class:" + className);
                return 0;
            }
            //设置允许访问，防止private修饰的构造方法
            constructor.setAccessible(true);
            Object object = constructor.newInstance(params);
            mObjectCache.put(object.hashCode(), object);

            Log.i(TAG, "west new object: " + object.hashCode());

            return object.hashCode();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Object getObject(int hashCode){
        return mObjectCache.get(hashCode);
    }

    public void releaseObject(int hashCode){
        mObjectCache.remove(hashCode);
    }



}
