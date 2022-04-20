//
// Created by hui on 2022/4/19.
//
#pragma once
#include <jni.h>

namespace dartnative {

void InitWithJavaVM(JavaVM *vm);

JNIEnv *AttachCurrentThread();

bool HasException(JNIEnv* env);

bool ClearException(JNIEnv* env);

}
