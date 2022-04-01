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

}