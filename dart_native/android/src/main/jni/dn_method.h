
#pragma once

#include <jni.h>
#include "dart_api_dl.h"

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

/**
 * Dart Method Wrapper.
 * */
class DNMethod {
 public:
  DNMethod(void *target,
           char *methodName,
           char **argsType,
           char *returnType,
           int argCount,
           Dart_Port dart_port,
           void *callback);

  void *InvokeNativeMethod(void **arguments,
                           uint32_t stringTypeBitmask,
                           int thread,
                           bool isInterface);

  void InvokeDartMethod();

 private:
  void *target_;
  char *methodName_;
  char **argsType_;
  char *returnType_;
  int argCount_;
  Dart_Port dart_port_;
  void *callback_;
};

}