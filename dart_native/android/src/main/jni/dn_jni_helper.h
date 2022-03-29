#pragma once

#include <jni.h>

namespace dartnative {

void InitWithJavaVM(JavaVM *vm);

JNIEnv *AttachCurrentThread();

void InitClazz();

jobject GetClassLoaderObj();

jclass GetStringClazz();

jmethodID GetFindClassMethod();

jclass FindClass(const char *name, JNIEnv *env = nullptr);

void FillArgs2JValues(void **arguments,
                      char **argumentTypes,
                      jvalue *argValues,
                      int argumentCount,
                      uint32_t stringTypeBitmask);

}