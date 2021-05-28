//
// Created by Hui on 5/27/21.
//
#include <stdint.h>
#include <jni.h>

#ifndef DART_NATIVE_DN_TYPE_CONVERT_H
#define DART_NATIVE_DN_TYPE_CONVERT_H
#ifdef __cplusplus
extern "C"
{
#endif

  jstring convertToJavaUtf16(JNIEnv *env, void *value);

  uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString);

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_TYPE_CONVERT_H
