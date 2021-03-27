package com.dartnative.dart_native;

import android.util.Log;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Created by huizzzhou on 3/26/21.
 */
public class ArrayListConverter {

    /************************basic type list to array***************************************/

    public byte[] byteListToArray(List<Byte> arguments) {
        byte[] byteArray = new byte[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            byteArray[i] = arguments.get(i);
        }
        return byteArray;
    }

    public short[] shortListToArray(List<Short> arguments) {
        short[] shortArray = new short[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            shortArray[i] = arguments.get(i);
        }
        return shortArray;
    }

    public long[] longListToArray(List<Long> arguments) {
        long[] longArray = new long[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            longArray[i] = arguments.get(i);
        }
        return longArray;
    }

    public int[] intListToArray(List<Integer> arguments) {
        int[] intArray = new int[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            intArray[i] = arguments.get(i);
        }
        return intArray;
    }

    public boolean[] boolListToArray(List<Boolean> arguments) {
        boolean[] boolArray = new boolean[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            boolArray[i] = arguments.get(i);
        }
        return boolArray;
    }

    public char[] charListToArray(List<Character> arguments) {
        char[] charArray = new char[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            charArray[i] = arguments.get(i);
        }
        return charArray;
    }

    public float[] floatListToArray(List<Float> arguments) {
        float[] floatArray = new float[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            floatArray[i] = arguments.get(i);
        }
        return floatArray;
    }

    public double[] doubleListToArray(List<Double> arguments) {
        double[] doubleArray = new double[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            doubleArray[i] = arguments.get(i);
        }
        return doubleArray;
    }

    /************************object type list to array***************************************/

    public Object[] objectListToArray(List<Object> arguments) {
        Object[] doubleArray = new Object[arguments.size()];
        for (int i = 0; i < arguments.size(); i++) {
            doubleArray[i] = arguments.get(i);
        }
        return doubleArray;
    }


    /************************array to list***************************************/

    public List arrayToList(Object array) {
        List arrayList;
        if (array instanceof byte[]) {
            arrayList = new ArrayList<Byte>();
            for (byte b : (byte []) array) {
                arrayList.add(b);
            }
        } else if (array instanceof short[]) {
            arrayList = new ArrayList<Short>();
            for (short s : (short []) array) {
                arrayList.add(s);
            }
        } else if (array instanceof long[]) {
            arrayList = new ArrayList<Long>();
            for (long l : (long []) array) {
                arrayList.add(l);
            }
        } else if (array instanceof int[]) {
            arrayList = new ArrayList<Integer>();
            for (int i : (int []) array) {
                arrayList.add(i);
            }
        } else if (array instanceof boolean[]) {
            arrayList = new ArrayList<Boolean>();
            for (boolean b : (boolean []) array) {
                arrayList.add(b);
            }
        } else if (array instanceof char[]) {
            arrayList = new ArrayList<Character>();
            for (char c : (char[]) array) {
                arrayList.add(c);
            }
        } else if (array instanceof float[]) {
            arrayList = new ArrayList<Float>();
            for (float f : (float[]) array) {
                arrayList.add(f);
            }
        } else if (array instanceof double[]) {
            arrayList = new ArrayList<Double>();
            for (double d : (double[]) array) {
                arrayList.add(d);
            }
        } else {
            arrayList = Collections.singletonList(array);
        }

        return arrayList;
    }
    
}
