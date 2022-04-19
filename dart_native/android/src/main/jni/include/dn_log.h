//
// Created by Hui on 5/27/21.
//

#ifndef DART_NATIVE_DN_LOG_H
#define DART_NATIVE_DN_LOG_H

#include <android/log.h>

#ifdef __cplusplus
extern "C"
{
#endif

#define DNDebug(...) __android_log_print(ANDROID_LOG_DEBUG, "DartNative", __VA_ARGS__)
#define DNInfo(...) __android_log_print(ANDROID_LOG_INFO, "DartNative", __VA_ARGS__)
#define DNError(...) __android_log_print(ANDROID_LOG_ERROR, "DartNative", __VA_ARGS__)

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_LOG_H
