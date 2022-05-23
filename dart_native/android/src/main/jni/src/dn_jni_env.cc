//
// Created by hui on 2022/4/19.
//
#include <thread>
#include "dn_log.h"
#include "dn_jni_env.h"

namespace dartnative {

static JavaVM *g_vm = nullptr;
static pthread_key_t detach_key = 0;

void InitWithJavaVM(JavaVM *vm) { g_vm = vm; }

void DetachThreadDestructor(void *arg) {
  DNDebug("detach from current thread");
  g_vm->DetachCurrentThread();
  detach_key = 0;
}

JNIEnv *AttachCurrentThread() {
  if (g_vm == nullptr) {
    return nullptr;
  }

  if (detach_key == 0) {
    pthread_key_create(&detach_key, DetachThreadDestructor);
  }
  JNIEnv *env;
  jint ret = g_vm->GetEnv((void **) &env, JNI_VERSION_1_6);

  switch (ret) {
    case JNI_OK:return env;
    case JNI_EDETACHED:DNDebug("attach to current thread");
      g_vm->AttachCurrentThread(&env, nullptr);
      return env;
    default:DNError("fail to get env");
      return nullptr;
  }
}

bool HasException(JNIEnv* env) {
  return env->ExceptionCheck() != JNI_FALSE;
}

bool ClearException(JNIEnv* env) {
  if (!HasException(env))
    return false;
  env->ExceptionDescribe();
  env->ExceptionClear();
  return true;
}

}
