//
// Created by hui on 2022/4/25.
//
#include <unordered_map>

#include "dn_jni_utils.h"
#include "dn_callback.h"
#include "dn_interface.h"
#include "dn_jni_env.h"
#include "dn_native_invoker.h"

namespace dartnative {

static JavaGlobalRef<jobject> *g_interface_registry = nullptr;
static jmethodID g_get_interface = nullptr;
static jmethodID g_get_signature = nullptr;
static jmethodID g_handle_response = nullptr;

static std::unordered_map<std::string, DartThreadInfo> dart_interface_thread_cache;
static std::unordered_map<std::string, std::unordered_map<std::string, NativeMethodCallback>>
    dart_interface_method_cache;

void Send2JavaErrorMessage(const std::string &error, jint response_id, JNIEnv *env) {
  JavaLocalRef<jstring> error_message(env->NewStringUTF(error.c_str()), env);
  env->CallVoidMethod(g_interface_registry->Object(),
                      g_handle_response,
                      response_id,
                      nullptr,
                      error_message.Object());
}

static void InterfaceNativeInvokeDart(JNIEnv *env,
                                      jobject obj,
                                      jstring interface_name,
                                      jstring method,
                                      jobjectArray arguments,
                                      jobjectArray argument_types,
                                      jint argument_count,
                                      jint response_id) {
  const char *interface_char = env->GetStringUTFChars(interface_name, NULL);
  const char *method_char = env->GetStringUTFChars(method, NULL);
  auto method_map = dart_interface_method_cache[std::string(interface_char)];
  auto dart_function = method_map[std::string(method_char)];
  if (dart_function == nullptr) {
    Send2JavaErrorMessage(std::string("Dart is not register function: %s", method_char),
                          response_id, env);
    return;
  }

  char **type_array = new char *[argument_count + 1];
  void **argument_array = new void *[argument_count + 1];

  /// store argument to pointer
  for (int i = 0; i < argument_count; ++i) {
    JavaLocalRef<jstring>
        argTypeString((jstring) env->GetObjectArrayElement(argument_types, i), env);
    JavaLocalRef<jobject> argument(env->GetObjectArrayElement(arguments, i), env);
    type_array[i] = (char *) env->GetStringUTFChars(argTypeString.Object(), NULL);
    if (strcmp(type_array[i], "java.lang.String") == 0) {
      /// argument will delete in JavaStringToDartString
      argument_array[i] = JavaStringToDartString(env, (jstring) argument.Object());
    } else {
      jobject gObj = env->NewGlobalRef(argument.Object());
      argument_array[i] = gObj;
    }
  }

  char *return_type = (char *) "java.lang.Object";
  /// the last pointer is return type
  type_array[argument_count] = return_type;

  auto thread_info = dart_interface_thread_cache[interface_char];

  jobject callbackResult =
      InvokeDartFunction(thread_info.thread_id == std::this_thread::get_id(),
                         dart_function,
                         (void *) interface_char,
                         (char *) method_char,
                         argument_array,
                         type_array,
                         argument_count,
                         return_type,
                         thread_info.dart_port,
                         env);

  env->CallVoidMethod(g_interface_registry->Object(), g_handle_response, response_id, callbackResult, nullptr);

  if (method_char != nullptr) {
    env->ReleaseStringUTFChars(method, method_char);
  }
  if (interface_char != nullptr) {
    env->ReleaseStringUTFChars(interface_name, interface_char);
  }
  delete[] argument_array;
  delete[] type_array;

}

void InitInterface(JNIEnv *env) {
  auto registryClz =
      FindClass("com/dartnative/dart_native/InterfaceRegistry", env);

  static const JNINativeMethod interface_jni_methods[] = {
      {
          .name = "nativeInvokeMethod",
          .signature = "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;[Ljava/lang/String;II)V",
          .fnPtr = (void *) InterfaceNativeInvokeDart
      }
  };
  if (env->RegisterNatives(registryClz.Object(), interface_jni_methods, 1) < 0) {
    return;
  }
  auto instanceID =
      env->GetStaticMethodID(registryClz.Object(),
                             "getInstance",
                             "()Lcom/dartnative/dart_native/InterfaceRegistry;");
  JavaGlobalRef<jobject>
      registryObj(env->CallStaticObjectMethod(registryClz.Object(), instanceID), env);
  g_interface_registry = new JavaGlobalRef<jobject>(registryObj.Object(), env);
  g_get_interface = env->GetMethodID(registryClz.Object(), "getInterface",
                                     "(Ljava/lang/String;)Ljava/lang/Object;");
  g_get_signature = env->GetMethodID(registryClz.Object(), "getMethodsSignature",
                                     "(Ljava/lang/String;)Ljava/lang/String;");
  g_handle_response = env->GetMethodID(registryClz.Object(), "handleInterfaceResponse",
                                       "(ILjava/lang/Object;Ljava/lang/String;)V");
  return;
}

void *InterfaceWithName(char *name, JNIEnv *env) {
  if (g_interface_registry == nullptr || g_get_interface == nullptr) {
    return nullptr;
  }

  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  if (interfaceName.IsNull()) {
    return nullptr;
  }

  auto interface =
      env->CallObjectMethod(g_interface_registry->Object(),
                            g_get_interface,
                            interfaceName.Object());
  return interface;
}

void *InterfaceMetaData(char *name, JNIEnv *env) {
  if (g_interface_registry == nullptr || g_get_signature == nullptr) {
    return nullptr;
  }

  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  if (interfaceName.IsNull()) {
    return nullptr;
  }

  JavaLocalRef<jstring> signatures((jstring) env->CallObjectMethod(g_interface_registry->Object(),
                                                                   g_get_signature,
                                                                   interfaceName.Object()), env);
  return JavaStringToDartString(env, signatures.Object());
}

void RegisterDartInterface(char *interface, char *method,
                           void *callback, Dart_Port dartPort) {
  auto interface_str = std::string(interface);
  auto method_cache = dart_interface_method_cache[interface_str];
  method_cache[std::string(method)] = (NativeMethodCallback) callback;
  dart_interface_method_cache[interface_str] = method_cache;
  dart_interface_thread_cache[interface_str] = {dartPort, std::this_thread::get_id()};
}

}
