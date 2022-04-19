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

namespace dartnative {

typedef void(*NativeMethodCallback)(void *targetPtr,
                                    char *funNamePtr,
                                    void **args,
                                    char **argTypes,
                                    int argCount);

typedef void(*InvokeCallback)(void *result,
                              char *method,
                              char **typePointers,
                              int argumentCount);

jstring ConvertToJavaUtf16(JNIEnv *env, void *value);

uint16_t *ConvertToDartUtf16(JNIEnv *env, jstring nativeString);

char *GenerateSignature(char **argumentTypes, int argumentCount, char *returnType);

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

}
