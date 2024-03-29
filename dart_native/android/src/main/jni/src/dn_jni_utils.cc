#include "dn_jni_utils.h"
#include "dn_log.h"
#include "dn_callback.h"

namespace dartnative {

static JavaGlobalRef<jobject> *g_class_loader = nullptr;
static jmethodID g_find_class_method = nullptr;
// for invoke result compare
static JavaGlobalRef<jclass> *g_str_clazz = nullptr;
// for ByteBuffer invoke
static JavaGlobalRef<jclass> *g_byte_buffer_clz = nullptr;

void InitClazz(JNIEnv *env) {
  /// cache classLoader
  JavaLocalRef<jclass> plugin(env->FindClass("com/dartnative/dart_native/DartNativePlugin"), env);
  if (plugin.IsNull()) {
    ClearException(env);
    DNError("Could not locate DartNativePlugin class!");
    return;
  }

  JavaLocalRef<jclass> pluginClass(env->GetObjectClass(plugin.Object()), env);
  JavaLocalRef<jclass> classLoaderClass(env->FindClass("java/lang/ClassLoader"), env);
  if (classLoaderClass.IsNull()) {
    ClearException(env);
    DNError("Could not locate ClassLoader class!");
    return;
  }

  auto getClassLoaderMethod = env->GetMethodID(pluginClass.Object(), "getClassLoader",
                                               "()Ljava/lang/ClassLoader;");
  if (getClassLoaderMethod == nullptr) {
    ClearException(env);
    DNError("Could not locate getClassLoader method!");
    return;
  }

  JavaLocalRef<jobject>
      classLoader(env->CallObjectMethod(plugin.Object(), getClassLoaderMethod), env);
  if (classLoader.IsNull()) {
    ClearException(env);
    DNError("Could not init classLoader!");
    return;
  }

  g_class_loader = new JavaGlobalRef<jobject>(classLoader.Object(), env);
  g_find_class_method = env->GetMethodID(classLoaderClass.Object(), "findClass",
                                         "(Ljava/lang/String;)Ljava/lang/Class;");
  if (g_find_class_method == nullptr) {
    ClearException(env);
    DNError("Could not locate findClass method!");
    return;
  }

  /// cache string class
  JavaLocalRef<jclass> strCls(env->FindClass("java/lang/String"), env);
  if (strCls.IsNull()) {
    ClearException(env);
    DNError("Could not locate java/lang/String class!");
    return;
  }
  g_str_clazz = new JavaGlobalRef<jclass>(strCls.Object(), env);

  JavaLocalRef<jclass> byte_buffer_clz(env->FindClass("java/nio/DirectByteBuffer"), env);
  if (byte_buffer_clz.IsNull()) {
    ClearException(env);
    DNError("Could not locate java/nio/DirectByteBuffer class!");
    return;
  }
  g_byte_buffer_clz = new JavaGlobalRef<jclass>(byte_buffer_clz.Object(), env);
}

jobject GetClassLoaderObj() {
  if (g_class_loader == nullptr) {
    return nullptr;
  }
  return g_class_loader->Object();
}

jclass GetStringClazz() {
  if (g_str_clazz == nullptr) {
    return nullptr;
  }
  return g_str_clazz->Object();
}

jclass GetDirectByteBufferClazz() {
  if (g_byte_buffer_clz == nullptr) {
    return nullptr;
  }
  return g_byte_buffer_clz->Object();
}

jmethodID GetFindClassMethod() {
  return g_find_class_method;
}

jstring DartStringToJavaString(JNIEnv *env, void *value) {
  if (value == nullptr) {
    return nullptr;
  }
  auto *utf16 = (uint16_t *) value;

  /// todo(HUIZZ) use uint64
  uint32_t length = 0;
  length += *utf16++ << 16;
  length += *utf16++;

  auto nativeString = env->NewString(utf16, length);
  free(value);

  return nativeString;
}

/// nativeString not null
uint16_t *JavaStringToDartString(JNIEnv *env, jstring nativeString) {
  if (nativeString == nullptr) {
    return nullptr;
  }
  const jchar *jc = env->GetStringChars(nativeString, nullptr);
  jsize strLength = env->GetStringLength(nativeString);

  /// check bom
  bool hasBom = jc[0] == 0xFEFF || jc[0] == 0xFFFE; // skip bom
  int indexStart = 0;
  if (hasBom) {
    strLength--;
    indexStart = 1;
    if (strLength <= 0) {
      env->ReleaseStringChars(nativeString, jc);
      return nullptr;
    }
  }

  /// do convert
  auto *utf16Str =
      static_cast<uint16_t *>(malloc(sizeof(uint16_t) * (strLength + 3)));
  /// save u16list length
  utf16Str[0] = strLength >> 16 & 0xFFFF;
  utf16Str[1] = strLength & 0xFFFF;
  int u16Index = 2;
  for (int i = indexStart; i < strLength; i++) {
    utf16Str[u16Index++] = jc[i];
  }
  utf16Str[strLength + 2] = '\0';

  env->ReleaseStringChars(nativeString, jc);
  return utf16Str;
}

/// Returns a malloc pointer to the result.
char *GenerateSignature(char **argumentTypes, int argumentCount, char *returnType) {
  /// include "(" ")" and blank length
  size_t signatureLength = strlen(returnType) + 3;
  /// all argument type length
  for (int i = 0; i < argumentCount; i++) {
    signatureLength += strlen(argumentTypes[i]);
  }

  char *signature = (char *) malloc(signatureLength * sizeof(char));
  strcpy(signature, "(");
  int offset = 1;
  for (int i = 0; i < argumentCount; offset += strlen(argumentTypes[i]), i++) {
    strcpy(signature + offset, argumentTypes[i]);
  }
  strcpy(signature + offset, ")");
  strcpy(signature + offset + 1, returnType);
  signature[signatureLength - 1] = '\0';

  return signature;
}

}
