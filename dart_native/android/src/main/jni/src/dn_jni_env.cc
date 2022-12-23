//
// Created by hui on 2022/4/19.
//
#include <thread>
#include "dn_log.h"
#include "dn_jni_env.h"

namespace dartnative {

static JavaVM *g_vm = nullptr;
static pthread_key_t t_key = 0;

void InitWithJavaVM(JavaVM *vm) { g_vm = vm; }

void DetachThreadDestructor(void *arg) {
  DNDebug("detach from current thread");
  g_vm->DetachCurrentThread();
  t_key = 0;
}

JNIEnv *AttachCurrentThread() {
  JNIEnv *env;
  env = (JNIEnv *)pthread_getspecific(t_key);
  if (env != nullptr) {
    return env;
  }

  if (g_vm == nullptr) {
    return nullptr;
  }

  if (t_key == 0) {
    pthread_key_create(&t_key, DetachThreadDestructor);
  }

  jint ret = g_vm->GetEnv((void **) &env, JNI_VERSION_1_6);

  switch (ret) {
    case JNI_OK:
      pthread_setspecific(t_key, env);
      return env;
    case JNI_EDETACHED:
      DNDebug("attach to current thread");
      g_vm->AttachCurrentThread(&env, nullptr);
      pthread_setspecific(t_key, env);
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
