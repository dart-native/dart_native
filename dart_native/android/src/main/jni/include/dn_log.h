//
// Created by Hui on 5/27/21.
//
#pragma once
#include <android/log.h>

namespace dartnative {

#define DNDebug(...) __android_log_print(ANDROID_LOG_DEBUG, "DartNative", __VA_ARGS__)
#define DNInfo(...) __android_log_print(ANDROID_LOG_INFO, "DartNative", __VA_ARGS__)
#define DNError(...) __android_log_print(ANDROID_LOG_ERROR, "DartNative", __VA_ARGS__)

}
