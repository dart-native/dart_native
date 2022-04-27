//
// Created by Hui on 6/1/21.
//
#include <string>
#include <semaphore.h>
#include <unordered_map>
#include "dn_native_invoker.h"
#include "jni_object_ref.h"
#include "dn_jni_utils.h"
#include "dn_dart_api.h"
#include "dn_callback.h"
#include "dn_log.h"

namespace dartnative {

static JavaGlobalRef<jclass> *g_callback_manager_clz = nullptr;
static jmethodID g_register_callback = nullptr;

struct CallbackInfo {
  NativeMethodCallback method_callback;
  Dart_Port dart_port;
  std::__thread_id thread_id;
};

// Dart callback info cache.
static std::unordered_map<int64_t, std::unordered_map<std::string, CallbackInfo>>
    g_dart_callback_info_map;
// Java proxy object cache.
static std::unordered_map<int64_t, JavaGlobalRef<jobject>> g_java_proxy_map;

static jobject HookNativeCallback(JNIEnv *env,
                                  jobject obj,
                                  jlong dart_object_address,
                                  jstring function_name,
                                  jint argument_count,
                                  jobjectArray argument_types,
                                  jobjectArray arguments_array,
                                  jstring return_type_str) {
  auto callbacks = g_dart_callback_info_map[dart_object_address];
  if (callbacks.empty()) {
    DNError("Invoke dart function error, not register this dart object!");
    return nullptr;
  }

  char *funName =
      function_name == nullptr ? nullptr : (char *) env->GetStringUTFChars(function_name, nullptr);
  if (funName == nullptr) {
    ClearException(env);
    DNError("Invoke dart function error, function name is null!");
    return nullptr;
  }
  auto callback_info = callbacks[funName];
  // When java return void, jstring which from native is null.
  char *return_type =
      return_type_str == nullptr ? nullptr : (char *) env->GetStringUTFChars(return_type_str, nullptr);

  // release jstring
  auto clear_fun = [=](jobject) {
    auto clear_env = AttachCurrentThread();
    if (clear_env == nullptr) {
      DNError("Clear_env error, clear_env no JNIEnv provided!");
      return;
    }

    if (return_type_str != nullptr) {
      clear_env->ReleaseStringUTFChars(return_type_str, return_type);
    }

    if (function_name != nullptr) {
      clear_env->ReleaseStringUTFChars(function_name, funName);
    }
  };

  auto callback_result =
      InvokeDartFunction(callback_info.thread_id == std::this_thread::get_id(),
                         0,
                         callback_info.method_callback,
                         (void *) dart_object_address,
                         funName,
                         arguments_array,
                         argument_types,
                         argument_count,
                         return_type,
                         callback_info.dart_port,
                         env,
                         clear_fun);

  return callback_result;
}

void InitCallback(JNIEnv *env) {
  auto manager_clz = FindClass("com/dartnative/dart_native/CallbackManager", env);
  if (manager_clz.IsNull()) {
    ClearException(env);
    DNError("Could not locate CallbackManager class!");
    return;
  }

  g_callback_manager_clz = new JavaGlobalRef<jclass>(manager_clz.Object(), env);
  g_register_callback = env->GetStaticMethodID(g_callback_manager_clz->Object(),
                                               "registerCallback",
                                               "(JLjava/lang/String;)Ljava/lang/Object;");
  if (g_register_callback == nullptr) {
    ClearException(env);
    DNError("Could not locate CallbackManager#registerCallback method!");
    return;
  }

  auto invocation_handler = FindClass("com/dartnative/dart_native/CallbackInvocationHandler", env);
  if (invocation_handler.IsNull()) {
    ClearException(env);
    DNError("InitInterface error, could not locate CallbackInvocationHandler class!");
    return;
  }

  static const JNINativeMethod interface_jni_methods[] = {
      {
          .name = "hookCallback",
          .signature = "(JLjava/lang/String;I[Ljava/lang/String;[Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;",
          .fnPtr = (void *) HookNativeCallback
      }
  };
  if (env->RegisterNatives(invocation_handler.Object(), interface_jni_methods, 1) < 0) {
    ClearException(env);
    DNError("InitCallback error, registerNatives error!");
  }
}

void DoRegisterNativeCallback(void *dart_object,
                              char *cls_name,
                              char *fun_name,
                              void *callback,
                              Dart_Port dart_port,
                              JNIEnv *env) {
  if (g_callback_manager_clz == nullptr || g_register_callback == nullptr) {
    DNError("DoRegisterNativeCallback error, g_callback_manager_clz or g_register_callback is null!");
    return;
  }
  auto dartObjectAddress = (int64_t) dart_object;
  // Creating interface object using java dynamic proxy.
  JavaLocalRef<jstring> newClsName(env->NewStringUTF(cls_name), env);
  JavaLocalRef<jobject> proxyObject(env->CallStaticObjectMethod(g_callback_manager_clz->Object(),
                                                                g_register_callback,
                                                                dart_port,
                                                                newClsName.Object()), env);
  auto callback_method_map = g_dart_callback_info_map[dartObjectAddress];
  callback_method_map[std::string(fun_name)] =
      {(NativeMethodCallback) callback, dart_port, std::this_thread::get_id()};
  g_dart_callback_info_map[dartObjectAddress] = callback_method_map;
  g_java_proxy_map[dartObjectAddress] = JavaGlobalRef<jobject>(proxyObject.Object(), env);
}

jobject GetNativeCallbackProxyObject(void *dart_object) {
  if (dart_object == nullptr) {
    return nullptr;
  }

  if (g_java_proxy_map.find((int64_t) dart_object) == g_java_proxy_map.end()) {
    return nullptr;
  }

  return g_java_proxy_map[(int64_t) dart_object].Object();
}

}
