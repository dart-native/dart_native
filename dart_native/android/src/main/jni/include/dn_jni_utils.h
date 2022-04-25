#pragma once
#include "jni_object_ref.h"

namespace dartnative {

void InitClazz(JNIEnv *env);

jobject GetClassLoaderObj();

jclass GetStringClazz();

jmethodID GetFindClassMethod();

jstring DartStringToJavaString(JNIEnv *env, void *value);

/**
 * Convert jstring to uint16 array, uint16 array will free in dart side.
 * */
uint16_t *JavaStringToDartString(JNIEnv *env, jstring nativeString);

char *GenerateSignature(char **argumentTypes, int argumentCount, char *returnType);

}
