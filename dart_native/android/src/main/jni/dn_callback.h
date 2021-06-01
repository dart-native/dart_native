//
// Created by Hui on 6/1/21.
//

#ifndef DART_NATIVE_DN_CALLBACK_H
#define DART_NATIVE_DN_CALLBACK_H

#include <jni.h>
#include <dart_api.h>
#include <map>

#ifdef __cplusplus
extern "C"
{
#endif

  typedef void (*NativeMethodCallback)(void *targetPtr, char *funNamePtr, void **args, char **argTypes, int argCount);

  void doRegisterNativeCallback(void *dartObject, jobject nativeProxyObject, char *funName, void *callback, Dart_Port dartPort);

  jobject getNativeCallbackProxyObject(void *dartObject);

  Dart_Port getCallbackDartPort(jlong dartObjectAddress);

  void *getDartObject(jlong dartObjectAddress);

  NativeMethodCallback getCallbackMethod(jlong dartObjectAddress, char *functionName);

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_CALLBACK_H
