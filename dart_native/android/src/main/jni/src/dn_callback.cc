//
// Created by Hui on 6/1/21.
//
#include <string>
#include <semaphore.h>
#include <unordered_map>
#include <unistd.h>
#include "dn_native_invoker.h"
#include "jni_object_ref.h"
#include "dn_jni_utils.h"
#include "dn_dart_api.h"
#include "dn_callback.h"
#include "dn_log.h"

namespace dartnative {

static JavaGlobalRef<jclass> *g_callback_manager_clz = nullptr;
// Register dart callback, this method will return java dynamic proxy object.
static jmethodID g_register_callback = nullptr;
static jmethodID g_unregister_callback = nullptr;

struct CallbackInfo {
  NativeMethodCallback method_callback = nullptr;
  Dart_Port dart_port = 0;
  uint64_t thread_id = 0;
};

// Dart callback info cache.
static std::unordered_map<int64_t, std::unordered_map<std::string, CallbackInfo>>
    g_dart_callback_info_map;
// Java proxy object cache.
static std::unordered_map<int64_t, JavaGlobalRef <jobject>> g_java_proxy_map;
std::mutex g_callback_map_mtx;

std::unordered_map<std::string, CallbackInfo> GetDartRegisterCallback(jlong dart_object_address) {
  std::lock_guard<std::mutex> lockGuard(g_callback_map_mtx);
  return g_dart_callback_info_map[dart_object_address];
}

JavaGlobalRef<jobject> RemoveDartRegisterCallback(jlong dart_object_address) {
  std::lock_guard<std::mutex> lockGuard(g_callback_map_mtx);
  g_dart_callback_info_map.erase(dart_object_address);
  auto proxy = g_java_proxy_map[dart_object_address];
  g_java_proxy_map.erase(dart_object_address);
  return proxy;
}

static jobject HookNativeCallback(JNIEnv *env,
                                  jobject obj,
                                  jlong dart_object_address,
                                  jstring function_name,
                                  jint argument_count,
                                  jobjectArray argument_types,
                                  jobjectArray arguments_array,
                                  jstring return_type_str,
                                  jboolean is_function_handler) {
  auto callbacks = GetDartRegisterCallback(dart_object_address);
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
  auto async_callback = [=](jobject) {
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
      InvokeDartFunction(callback_info.thread_id == static_cast<uint64_t>(gettid()),
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
                         async_callback);

  if (is_function_handler) {
    RemoveDartRegisterCallback(dart_object_address);
  }

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

  g_unregister_callback = env->GetStaticMethodID(g_callback_manager_clz->Object(),
                                                 "unRegisterCallback",
                                                 "(Ljava/lang/Object;)V");
  if (g_unregister_callback == nullptr) {
    ClearException(env);
    DNError("Could not locate CallbackManager#unRegisterCallback method!");
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
          .signature = "(JLjava/lang/String;I[Ljava/lang/String;[Ljava/lang/Object;Ljava/lang/String;Z)Ljava/lang/Object;",
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
  if (g_callback_manager_clz == nullptr || g_callback_manager_clz->IsNull()
      || g_register_callback == nullptr) {
    DNError("DoRegisterNativeCallback error, g_callback_manager_clz or g_register_callback is null!");
    return;
  }

  if (cls_name == nullptr) {
    DNError("DoRegisterNativeCallback error, class name is null!");
    return;
  }

  auto dart_object_address = (int64_t) dart_object;
  // Creating interface object using java dynamic proxy.
  JavaLocalRef<jstring> new_cls_name(env->NewStringUTF(cls_name), env);
  JavaLocalRef<jobject> proxy_object(env->CallStaticObjectMethod(g_callback_manager_clz->Object(),
                                                                 g_register_callback,
                                                                 dart_object_address,
                                                                 new_cls_name.Object()), env);
  if (ClearException(env) || proxy_object.IsNull()) {
    DNError("DoRegisterNativeCallback error, register callback error!");
    return;
  }
  std::lock_guard<std::mutex> lockGuard(g_callback_map_mtx);
  auto callback_method_map = g_dart_callback_info_map[dart_object_address];
  callback_method_map[std::string(fun_name)] =
      {(NativeMethodCallback) callback, dart_port, static_cast<uint64_t>(gettid())};
  g_dart_callback_info_map[dart_object_address] = callback_method_map;
  g_java_proxy_map[dart_object_address] = JavaGlobalRef<jobject>(proxy_object.Object(), env);
}

void DoUnregisterNativeCallback(void *dart_object, JNIEnv *env) {
  auto proxy = RemoveDartRegisterCallback((int64_t) dart_object);

  if (g_callback_manager_clz == nullptr || g_callback_manager_clz->IsNull()
      || g_unregister_callback == nullptr) {
    DNError("DoUnregisterNativeCallback error, class or unregister method is null!");
    return;
  }
  if (!proxy.IsNull()) {
    env->CallStaticVoidMethod(g_callback_manager_clz->Object(), g_unregister_callback,
                              proxy.Object());
    if (ClearException(env)) {
      DNError("Unregister native callback error!");
    }
  }
}

jobject GetNativeCallbackProxyObject(void *dart_object) {
  if (dart_object == nullptr) {
    return nullptr;
  }
  std::lock_guard<std::mutex> lockGuard(g_callback_map_mtx);
  auto it = g_java_proxy_map.find((int64_t) dart_object);
  if (it == g_java_proxy_map.end()) {
    return nullptr;
  }

  return it->second.Object();
}
}
