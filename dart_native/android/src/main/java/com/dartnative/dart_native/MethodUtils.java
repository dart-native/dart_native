package com.dartnative.dart_native;

import java.lang.reflect.Method;

public class MethodUtils {

	public static String getClassSignature(Class clazz) {
		if (clazz == boolean.class) {
			return "Z";
		}

		if (clazz == double.class) {
			return "D";
		}

		if (clazz == int.class) {
			return "I";
		}

		if (clazz == float.class) {
			return "F";
		}

		if (clazz == long.class) {
			return "J";
		}

		if (clazz == void.class) {
			return "V";
		}

		if (clazz.getName().startsWith("[")) {
			return clazz.getName();
		}

		return "L" + clazz.getCanonicalName().replace(".", "/") + ";";
	}

	public static String buildSignature(Method method) {
		Class[] paramTypes = method.getParameterTypes();

		StringBuilder sb = new StringBuilder();
		sb.append(getClassSignature(method.getReturnType()));
		for (Class paramType : paramTypes) {
			sb.append("'");
			sb.append(getClassSignature(paramType));
		}
		return sb.toString();
	}
}
