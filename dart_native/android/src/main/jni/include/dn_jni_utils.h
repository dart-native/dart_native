#pragma once
#include "jni_object_ref.h"

namespace dartnative {

void InitClazz();

jobject GetClassLoaderObj();

jclass GetStringClazz();

jmethodID GetFindClassMethod();

jstring DartStringToJavaString(JNIEnv *env, void *value);

uint16_t *JavaStringToDartString(JNIEnv *env, jstring nativeString);

char *GenerateSignature(char **argumentTypes, int argumentCount, char *returnType);

}
