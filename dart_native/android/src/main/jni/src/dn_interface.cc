//
// Created by hui on 2022/4/25.
//
#include <unordered_map>
#include "dn_dart_api.h"
#include "dn_jni_utils.h"
#include "dn_callback.h"
#include "dn_interface.h"
#include "dn_jni_env.h"
#include "dn_native_invoker.h"
#include "dn_log.h"

namespace dartnative {

// interface registry instance object.
static JavaGlobalRef<jobject> *g_interface_registry = nullptr;
// Get registered interface from java.
static jmethodID g_get_interface = nullptr;
// Get registered method signature from java.
static jmethodID g_get_signature = nullptr;
// Send result to java when java invoke dart function,
static jmethodID g_handle_response = nullptr;

struct DartInterfaceInfo {
  NativeMethodCallback method_callback;
  int return_async;
  Dart_Port dart_port;
};

// Interface cache which registered in dart side.
static std::unordered_map<std::string, std::unordered_map<std::string, DartInterfaceInfo>>
    dart_interface_method_cache;

void Send2JavaErrorMessage(const std::string &error, jint response_id, JNIEnv *env) {
  JavaLocalRef<jstring> error_message(env->NewStringUTF(error.c_str()), env);
  if (!g_interface_registry || g_interface_registry->IsNull() || !g_handle_response) {
    DNError(
        "Send2JavaErrorMessage error interface registry object or g_handle_response method id is null!");
    return;
  }
  env->CallVoidMethod(g_interface_registry->Object(),
                      g_handle_response,
                      response_id,
                      nullptr,
                      error_message.Object());
  if (ClearException(env)) {
    DNError("Send2JavaErrorMessage error, call handleInterfaceResponse error!");
  }
}

static void InvokeDart(jstring interface_name,
                       jstring method,
                       jobjectArray arguments,
                       jobjectArray argument_types,
                       jint argument_count,
                       jint response_id) {
  auto env = AttachCurrentThread();
  if (env == nullptr) {
    DNError("InterfaceNativeInvokeDart error, no JNIEnv provided!");
    return;
  }
  const char *interface_char = env->GetStringUTFChars(interface_name, NULL);
  const char *method_char = env->GetStringUTFChars(method, NULL);
  auto method_map = dart_interface_method_cache[std::string(interface_char)];
  auto dart_function = method_map[std::string(method_char)];
  if (dart_function.method_callback == nullptr) {
    Send2JavaErrorMessage(std::string("Dart is not register function: %s", method_char),
                          response_id, env);
    return;
  }

  // release jstring and global reference
  auto async_callback = [=](jobject ret) {
    auto clear_env = AttachCurrentThread();
    if (clear_env == nullptr) {
      DNError("Clear_env error, clear_env no JNIEnv provided!");
      return;
    }

    if (g_interface_registry && !g_interface_registry->IsNull() && g_handle_response) {
      clear_env->CallVoidMethod(g_interface_registry->Object(),
                                g_handle_response,
                                response_id,
                                ret,
                                nullptr);
      if (ClearException(clear_env)) {
        DNError("Call handleInterfaceResponse error!");
      }
    } else {
      DNError("Call handleInterfaceResponse error interface registry object or method id is null!");
    }

    if (method_char != nullptr) {
      clear_env->ReleaseStringUTFChars(method, method_char);
    }
    if (interface_char != nullptr) {
      clear_env->ReleaseStringUTFChars(interface_name, interface_char);
    }
    clear_env->DeleteGlobalRef(interface_name);
    clear_env->DeleteGlobalRef(method);
    clear_env->DeleteGlobalRef(arguments);
    clear_env->DeleteGlobalRef(argument_types);
  };

  InvokeDartFunction(false,
                     dart_function.return_async,
                     dart_function.method_callback,
                     (void *) interface_char,
                     (char *) method_char,
                     arguments,
                     argument_types,
                     argument_count,
                     (char *) "java.lang.Object",
                     dart_function.dart_port,
                     env,
                     async_callback);
}

static void InterfaceNativeInvokeDart(JNIEnv *env,
                                      jobject obj,
                                      jstring interface_name,
                                      jstring method,
                                      jobjectArray arguments,
                                      jobjectArray argument_types,
                                      jint argument_count,
                                      jint response_id) {
  auto interface_name_global = (jstring) env->NewGlobalRef(interface_name);
  auto method_global = (jstring) env->NewGlobalRef(method);
  auto arguments_global = (jobjectArray) env->NewGlobalRef(arguments);
  auto argument_types_global = (jobjectArray) env->NewGlobalRef(argument_types);
  // Run in sub thread.
  ScheduleInvokeTask(TaskThread::kSub,
                     [interface_name_global, method_global, arguments_global, argument_types_global, argument_count, response_id]() {
                       InvokeDart(interface_name_global, method_global,
                                  arguments_global, argument_types_global, argument_count,
                                  response_id);
                     });
}

void InitInterface(JNIEnv *env) {
  auto messenger_clz =
      FindClass("com/dartnative/dart_native/InterfaceMessenger", env);
  if (messenger_clz.IsNull()) {
    ClearException(env);
    DNError("InitInterface error, messenger_clz is null!");
    return;
  }

  static const JNINativeMethod interface_jni_methods[] = {
      {
          .name = "nativeInvokeMethod",
          .signature = "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/String;II)V",
          .fnPtr = (void *) InterfaceNativeInvokeDart
      }
  };
  if (env->RegisterNatives(messenger_clz.Object(), interface_jni_methods, 1) < 0) {
    ClearException(env);
    DNError("InitInterface error, registerNatives error!");
    return;
  }

  auto instance_id =
      env->GetStaticMethodID(messenger_clz.Object(),
                             "getInstance",
                             "()Lcom/dartnative/dart_native/InterfaceMessenger;");
  if (instance_id == nullptr) {
    ClearException(env);
    DNError("Could not locate InterfaceMessenger#getInstance method!");
    return;
  }

  JavaLocalRef<jobject>
      registryObj(env->CallStaticObjectMethod(messenger_clz.Object(), instance_id), env);
  if (registryObj.IsNull()) {
    ClearException(env);
    DNError("Could not init registryObj!");
    return;
  }

  g_interface_registry = new JavaGlobalRef<jobject>(registryObj.Object(), env);

  g_get_interface = env->GetMethodID(messenger_clz.Object(), "getInterface",
                                     "(Ljava/lang/String;)Ljava/lang/Object;");
  if (g_get_interface == nullptr) {
    ClearException(env);
    DNError("Could not locate InterfaceMessenger#getInterface method!");
    return;
  }

  g_get_signature = env->GetMethodID(messenger_clz.Object(), "getMethodsSignature",
                                     "(Ljava/lang/String;)Ljava/lang/String;");
  if (g_get_signature == nullptr) {
    ClearException(env);
    DNError("Could not locate InterfaceMessenger#getMethodsSignature method!");
    return;
  }

  g_handle_response = env->GetMethodID(messenger_clz.Object(), "handleInterfaceResponse",
                                       "(ILjava/lang/Object;Ljava/lang/String;)V");
  if (g_handle_response == nullptr) {
    ClearException(env);
    DNError("Could not locate InterfaceMessenger#handleInterfaceResponse method!");
    return;
  }
}

void *InterfaceWithName(char *name, JNIEnv *env) {
  if (!g_interface_registry || g_interface_registry->IsNull() || !g_get_interface) {
    DNError("InterfaceWithName error, g_interface_registry or g_get_interface is null!");
    return nullptr;
  }

  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  if (interfaceName.IsNull()) {
    ClearException(env);
    DNError("InterfaceWithName error, interfaceName is null!");
    return nullptr;
  }

  auto interface =
      env->CallObjectMethod(g_interface_registry->Object(),
                            g_get_interface,
                            interfaceName.Object());
  if (ClearException(env)) {
    DNError("InterfaceWithName error, get native interface object error!");
    return nullptr;
  }
  return interface;
}

void *InterfaceMetaData(char *name, JNIEnv *env) {
  if (!g_interface_registry || g_interface_registry->IsNull() || !g_get_interface) {
    DNError("InterfaceMetaData error, g_interface_registry or g_get_interface is null!");
    return nullptr;
  }

  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  if (interfaceName.IsNull()) {
    ClearException(env);
    DNError("InterfaceMetaData error, interfaceName is null!");
    return nullptr;
  }

  JavaLocalRef<jstring> signatures((jstring) env->CallObjectMethod(g_interface_registry->Object(),
                                                                   g_get_signature,
                                                                   interfaceName.Object()), env);
  if (ClearException(env)) {
    DNError("InterfaceMetaData error, get interface signature error!");
    return nullptr;
  }
  return JavaStringToDartString(env, signatures.Object());
}

void RegisterDartInterface(char *interface, char *method, void *callback, Dart_Port dartPort,
                           int32_t return_async) {
  auto interface_str = std::string(interface);
  auto method_cache = dart_interface_method_cache[interface_str];
  method_cache[std::string(method)] = {(NativeMethodCallback) callback, return_async, dartPort};
  dart_interface_method_cache[interface_str] = method_cache;
}

}
