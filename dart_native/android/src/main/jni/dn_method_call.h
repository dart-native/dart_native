//
// Created by Hui on 5/31/21.
//
#ifndef DART_NATIVE_DN_METHOD_CALL_H
#define DART_NATIVE_DN_METHOD_CALL_H

#include <stdint.h>
#include <jni.h>
#include <map>
#include <string>
#include "jni_object_ref.h"

#ifdef __cplusplus
extern "C"
{
#endif

using namespace dartnative;

typedef void *CallNativeMethod(JNIEnv *, jobject, jmethodID, jvalue *);

void *callNativeStringMethod(JNIEnv *env,
                             jobject object,
                             jmethodID methodId,
                             jvalue *arguments);

std::map<char, std::function<CallNativeMethod>> GetMethodCallerMap();

void FillArgs2JValues(void **arguments,
                      char **argumentTypes,
                      jvalue *argValues,
                      int argumentCount,
                      uint32_t stringTypeBitmask,
                      JavaLocalRef<jobject> jObjBucket[]);

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_METHOD_CALL_H
