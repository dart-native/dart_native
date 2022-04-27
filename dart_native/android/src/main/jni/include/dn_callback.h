//
// Created by Hui on 6/1/21.
//
/// todo(huizz): use wrapper callback
#pragma once
#include <jni.h>
#include <dart_api.h>
#include <map>
#include <thread>

namespace dartnative {

typedef void(*NativeMethodCallback)(void *targetPtr,
                                    char *funNamePtr,
                                    void **args,
                                    char **argTypes,
                                    int argCount,
                                    int return_async);

void InitCallback(JNIEnv *env);

void DoRegisterNativeCallback(void *dart_object,
                              char *cls_name,
                              char *fun_name,
                              void *callback,
                              Dart_Port dart_port,
                              JNIEnv *env);

jobject GetNativeCallbackProxyObject(void *dart_object);
}
