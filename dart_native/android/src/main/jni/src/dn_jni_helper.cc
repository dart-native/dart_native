#include "dn_jni_helper.h"
#include "dn_log.h"
#include "dn_callback.h"

namespace dartnative {

static JavaGlobalRef<jobject> *g_class_loader = nullptr;
static jmethodID g_find_class_method;
/// for invoke result compare
static JavaGlobalRef<jclass> *g_str_clazz = nullptr;

void InitClazz() {
  auto env = AttachCurrentThread();
  if (env == nullptr) {
    DNError("No JNIEnv provided");
    return;
  }

  /// cache classLoader
  JavaLocalRef<jclass> plugin(env->FindClass("com/dartnative/dart_native/DartNativePlugin"), env);
  if (plugin.IsNull()) {
    DNError("Could not locate DartNativePlugin class");
    return;
  }

  JavaLocalRef<jclass> pluginClass(env->GetObjectClass(plugin.Object()), env);
  JavaLocalRef<jclass> classLoaderClass(env->FindClass("java/lang/ClassLoader"), env);
  if (classLoaderClass.IsNull()) {
    DNError("Could not locate ClassLoader class");
    return;
  }

  auto getClassLoaderMethod = env->GetMethodID(pluginClass.Object(), "getClassLoader",
                                               "()Ljava/lang/ClassLoader;");
  if (getClassLoaderMethod == nullptr) {
    DNError("Could not locate getClassLoader method");
    return;
  }

  JavaLocalRef<jobject>
      classLoader(env->CallObjectMethod(plugin.Object(), getClassLoaderMethod), env);
  g_class_loader =
      new JavaGlobalRef<jobject>(env->NewGlobalRef(classLoader.Object()), env);
  if (g_class_loader->IsNull()) {
    DNError("Could not init g_class_loader");
    return;
  }
  g_find_class_method = env->GetMethodID(classLoaderClass.Object(), "findClass",
                                         "(Ljava/lang/String;)Ljava/lang/Class;");
  if (g_find_class_method == nullptr) {
    DNError("Could not locate findClass method");
    return;
  }

  /// cache string class
  JavaLocalRef<jclass> strCls(env->FindClass("java/lang/String"), env);
  g_str_clazz =
      new JavaGlobalRef<jclass>(strCls.Object(), env);
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

JavaLocalRef<jclass> FindClass(const char *name, JNIEnv *env) {
  if (env == nullptr) {
    env = AttachCurrentThread();
  }
  JavaLocalRef<jclass> nativeClass(env->FindClass(name), env);
  jthrowable exception = env->ExceptionOccurred();
  /// class loader not found class
  if (exception) {
    env->ExceptionClear();
    JavaLocalRef<jstring> clsName(env->NewStringUTF(name), env);
    JavaLocalRef<jclass>
        findedClass(static_cast<jclass>(env->CallObjectMethod(g_class_loader->Object(),
                                                              g_find_class_method,
                                                              clsName.Object())), env);
    return findedClass;
  }
  return nativeClass;
}

}
