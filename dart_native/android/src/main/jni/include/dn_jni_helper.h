#pragma once
#include "jni_object_ref.h"

namespace dartnative {

void InitClazz();

jobject GetClassLoaderObj();

jclass GetStringClazz();

jmethodID GetFindClassMethod();

JavaLocalRef<jclass> FindClass(const char *name, JNIEnv *env = nullptr);

}
