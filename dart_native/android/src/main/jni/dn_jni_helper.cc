#include <thread>
#include "dn_jni_helper.h"
#include "dn_log.h"
#include "jni_object_ref.h"
#include "dn_type_convert.h"
#include "dn_callback.h"

namespace dartnative {

static JavaVM *g_vm = nullptr;
static pthread_key_t detach_key = 0;

static JavaGlobalRef<jobject> *g_class_loader = nullptr;
static jmethodID g_find_class_method;
/// for invoke result compare
static JavaGlobalRef<jclass> *g_str_clazz = nullptr;

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

void InitClazz() {
  auto env = AttachCurrentThread();
  /// cache classLoader
  auto plugin = env->FindClass("com/dartnative/dart_native/DartNativePlugin");
  jclass pluginClass = env->GetObjectClass(plugin);
  auto classLoaderClass = env->FindClass("java/lang/ClassLoader");
  auto getClassLoaderMethod = env->GetMethodID(pluginClass, "getClassLoader",
                                               "()Ljava/lang/ClassLoader;");
  auto classLoader = env->CallObjectMethod(plugin, getClassLoaderMethod);
  g_class_loader =
      new JavaGlobalRef<jobject>(env->NewGlobalRef(classLoader), env);
  g_find_class_method = env->GetMethodID(classLoaderClass, "findClass",
                                         "(Ljava/lang/String;)Ljava/lang/Class;");

  /// cache string class
  jclass strCls = env->FindClass("java/lang/String");
  g_str_clazz =
      new JavaGlobalRef<jclass>(static_cast<jclass>(env->NewGlobalRef(strCls)), env);

  env->DeleteLocalRef(classLoader);
  env->DeleteLocalRef(plugin);
  env->DeleteLocalRef(pluginClass);
  env->DeleteLocalRef(classLoaderClass);
  env->DeleteLocalRef(strCls);
}

jobject GetClassLoaderObj() {
  return g_class_loader->Object();
}

jclass GetStringClazz() {
  return g_str_clazz->Object();
}

jmethodID GetFindClassMethod() {
  return g_find_class_method;
}

jclass FindClass(const char *name, JNIEnv *env) {
  if (env == nullptr) {
    env = AttachCurrentThread();
  }
  jclass nativeClass;
  nativeClass = env->FindClass(name);
  jthrowable exception = env->ExceptionOccurred();
  /// class loader not found class
  if (exception) {
    env->ExceptionClear();
    jstring clsName = env->NewStringUTF(name);
    auto findedClass =
        static_cast<jclass>(env->CallObjectMethod(g_class_loader->Object(),
                                                  g_find_class_method,
                                                  clsName));
    env->DeleteLocalRef(clsName);
    return findedClass;
  }
  return nativeClass;
}

void _deleteArgs(jvalue *argValues, int argumentCount, uint32_t stringTypeBitmask) {
  JNIEnv *env = AttachCurrentThread();
  for (jsize index(0); index < argumentCount; ++index) {
    /// release local reference of jstring
    if ((stringTypeBitmask >> index & 0x1) == 1) {
      env->DeleteLocalRef(argValues[index].l);
    }
  }
  delete[] argValues;
}

/// todo(HUIZZ) release arguments
void FillArgs2JValues(void **arguments,
                      char **argumentTypes,
                      jvalue *argValues,
                      int argumentCount,
                      uint32_t stringTypeBitmask) {
  if (argumentCount == 0) {
    return;
  }

  JNIEnv *env = AttachCurrentThread();
  for (jsize index(0); index < argumentCount; ++arguments, ++index) {
    /// check basic map convert
    auto map = GetTypeConvertMap();
    auto it = map.find(*argumentTypes[index]);

    if (it == map.end()) {
      /// when argument type is string or stringTypeBitmask mark as string
      if ((stringTypeBitmask >> index & 0x1) == 1) {
        argValues[index].l = convertToJavaUtf16(env, *arguments);
      } else {
        /// convert from object cache
        /// check callback cache, if true using proxy object
        jobject object = getNativeCallbackProxyObject(*arguments);
        argValues[index].l =
            object == nullptr ? static_cast<jobject>(*arguments) : object;
      }
    } else {
      auto isTwoPointer = it->second(arguments, argValues, index);
      /// In Dart use two pointer store value.
      if (isTwoPointer) {
        arguments++;
      }
    }
  }
}

}
