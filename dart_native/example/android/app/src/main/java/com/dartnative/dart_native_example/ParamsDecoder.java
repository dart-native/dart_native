package com.dartnative.dart_native_example;

import android.util.Log;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ParamsDecoder {
    public static final String TAG = "ParamsDecoder";

    public static final byte INT_TYPE = 0;

    public static ParamsDecoder sParamsDecoder;

    public static synchronized ParamsDecoder getInstance() {
        if (null == sParamsDecoder) {
            sParamsDecoder = new ParamsDecoder();
        }
        return sParamsDecoder;
    }

    public Object[] decode(byte[] buffer) {
        if (null == buffer) {
            return new Object[0];
        }

        List<Object> params = new ArrayList<>();
        int index = 0;
        while (index < buffer.length) {
            byte type = buffer[index];
            switch (type) {
                case INT_TYPE:
                    params.add(buffer[index + 1] | (buffer[index + 2] << 8) | (buffer[index + 3] << 16) | (buffer[index + 4] << 24));
                    index += 5;
                    break;
                default:
                    break;
            }
        }
        return params.toArray();
    }

    public byte[] encode(Object object) {
        if (object.getClass() == int.class || object.getClass() == Integer.class) {
            int result = (int) object;
            byte[] bytes = new byte[]{INT_TYPE, (byte) (result & 0xff), (byte) ((result >> 8) & 0xff), (byte) ((result >> 16) & 0xff), (byte) ((result >> 24) & 0xff)};
            return bytes;
        }
        return new byte[0];
    }

    /**
     * 根据参数找到合适的构造函数
     *
     * @param clazz
     * @param params
     * @return
     */
    public Constructor getSuteableConstructor(Class clazz, Object[] params) {
        Constructor[] constructors = clazz.getDeclaredConstructors();
        for (Constructor constructor : constructors) {
            if (constructureSuteable(constructor, params)) {
                return constructor;
            }
        }
        return null;
    }

    /**
     * 根据参数找到合适的方法
     *
     * @param clazz
     * @param params
     * @return
     */
    public Method getSuteableMethod(Class clazz, String methodName, Object[] params) {
        try {
            Method[] methods = clazz.getMethods();
            for (Method method : methods) {
                if (method.getName().equals(methodName)) {
                    if (methodSuteable(method, params)) {
                        return method;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * 判断构造函数是否适用于传递的参数
     *
     * @return
     */
    public boolean constructureSuteable(Constructor constructor, Object[] params) {
        Class[] constructorParamTypes = constructor.getParameterTypes();
        Class[] paramTypes = getParamTypes(params);
        if (typesSuteable(paramTypes, constructorParamTypes)) {
            return true;
        }
        return false;

    }

    /**
     * 判断方法是否适用于传递的参数
     *
     * @return
     */
    public boolean methodSuteable(Method method, Object[] params) {
        Class[] constructorParamTypes = method.getParameterTypes();
        Class[] paramTypes = getParamTypes(params);
        if (typesSuteable(paramTypes, constructorParamTypes)) {
            return true;
        }
        return false;

    }

    private boolean specialSute(Class a, Class b) {
        if (a == int.class && b == Integer.class) {
            return true;
        }

        if (b == int.class && a == Integer.class) {
            return true;
        }

        return false;
    }

    /**
     * clazzsFrom 是实际传递的参数类型，clazzsTo是形参类型
     *
     * @param clazzsFrom
     * @param clazzsTo
     * @return
     */
    private boolean typesSuteable(Class[] clazzsFrom, Class[] clazzsTo) {
        if (clazzsFrom == null && clazzsTo == null) {
            return true;
        }

        if (clazzsFrom.length != clazzsTo.length) {
            return false;
        }

        for (int i = 0; i < clazzsFrom.length; i++) {
            Class from = clazzsFrom[i];
            Class to = clazzsTo[i];
            //Integer.class.isAssignableFrom(Object.class) false
            //Object.class.isAssignableFrom(Integer.class) true 表示Integer继承自Object
            if (to.isAssignableFrom(from)) {
                //参数可传递
                continue;
            }

            if (specialSute(from, to)) {
                //参数可传递
                continue;
            }

            return false;

        }

        return true;
    }


    public static Class[] getParamTypes(Object[] params) {
        Class[] result = new Class[params.length];
        for (int i = 0; i < params.length; i++) {
            result[i] = params[i].getClass();
        }
        return result;
    }
}
