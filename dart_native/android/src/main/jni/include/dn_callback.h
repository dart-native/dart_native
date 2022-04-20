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

struct DartThreadInfo {
  Dart_Port dart_port;
  std::__thread_id thread_id;
};

typedef void(*NativeMethodCallback)(void *targetPtr,
                                    char *funNamePtr,
                                    void **args,
                                    char **argTypes,
                                    int argCount);

void doRegisterNativeCallback(void *dartObject,
                              jobject nativeProxyObject,
                              char *funName,
                              void *callback,
                              Dart_Port dartPort);

jobject getNativeCallbackProxyObject(void *dartObject);

Dart_Port getCallbackDartPort(jlong dartObjectAddress);

NativeMethodCallback
getCallbackMethod(jlong dartObjectAddress, char *functionName);

bool IsCurrentThread(jlong dartObjectAddress, std::__thread_id currentThread);

jobject InvokeDartFunction(bool is_same_thread,
                           NativeMethodCallback method_callback,
                           void *target,
                           char *funName,
                           void **arguments,
                           char **dataTypes,
                           int argumentCount,
                           char *return_type,
                           Dart_Port port,
                           JNIEnv *env);

}