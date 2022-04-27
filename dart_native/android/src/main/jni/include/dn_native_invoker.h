//
// Created by Hui on 5/31/21.
//
#pragma once

#include <stdint.h>
#include <jni.h>
#include <map>
#include <string>
#include "dart_api.h"
#include "jni_object_ref.h"
#include "dn_thread.h"
#include "dn_callback.h"

namespace dartnative {

typedef void(*InvokeCallback)(void *result, char *method, char **typePointers, int argumentCount);


JavaLocalRef<jclass> FindClass(const char *name, JNIEnv *env = nullptr);

JavaLocalRef<jobject> NewObject(jclass cls,
                                void **arguments,
                                char **argumentTypes,
                                int argumentCount,
                                uint32_t stringTypeBitmask);

jvalue *ConvertArgs2JValues(void **arguments,
                            char **argumentTypes,
                            int argumentCount,
                            uint32_t stringTypeBitmask,
                            JavaLocalRef<jobject> jObjBucket[]);


void *DoInvokeNativeMethod(jobject object,
                           char *methodName,
                           void **arguments,
                           char **typePointers,
                           int argumentCount,
                           char *returnType,
                           uint32_t stringTypeBitmask,
                           void *callback,
                           Dart_Port dartPort,
                           TaskThread thread);

jobject InvokeDartFunction(bool is_same_thread,
                           int return_async,
                           NativeMethodCallback method_callback,
                           void *target,
                           char *method_name,
                           jobjectArray arguments,
                           jobjectArray argument_types,
                           int argumentCount,
                           char *return_type,
                           Dart_Port port,
                           JNIEnv *env,
                           std::function<void(jobject)> clear_fun);

jobject ConvertDartValue2JavaValue(char *return_type, void *dart_value, JNIEnv *env = nullptr);

}
