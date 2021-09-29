//
// Created by Hui on 5/27/21.
//
#ifndef DART_NATIVE_DN_TYPE_CONVERT_H
#define DART_NATIVE_DN_TYPE_CONVERT_H

#include <stdint.h>
#include <jni.h>
#include <map>

#ifdef __cplusplus
extern "C"
{
#endif

typedef void BasicTypeToNative(void *, jvalue *, int);

jstring convertToJavaUtf16(JNIEnv *env, void *value);

uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString);

std::map<char, std::function<BasicTypeToNative>> GetTypeConvertMap();

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_TYPE_CONVERT_H
