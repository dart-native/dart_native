//
// Created by Hui on 5/31/21.
//
#pragma once

#include <stdint.h>
#include <jni.h>
#include <map>
#include <string>
#include "jni_object_ref.h"

namespace dartnative {

typedef void *CallNativeMethod(JNIEnv *, jobject, jmethodID, jvalue *);

void *callNativeStringMethod(JNIEnv *env,
                             jobject object,
                             jmethodID methodId,
                             jvalue *arguments);

std::map<char, std::function<CallNativeMethod>> GetMethodCallerMap();

jstring ConvertToJavaUtf16(JNIEnv *env, void *value);

uint16_t *ConvertToDartUtf16(JNIEnv *env, jstring nativeString);

void FillArgs2JValues(void **arguments,
                      char **argumentTypes,
                      jvalue *argValues,
                      int argumentCount,
                      uint32_t stringTypeBitmask,
                      JavaLocalRef<jobject> jObjBucket[]);

}
