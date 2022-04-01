//
// Created by Hui on 5/31/21.
//
#include "dn_method_call.h"
#include "dn_log.h"
#include "dn_callback.h"

namespace dartnative {

#define IS_32_BITS sizeof(void *) == 4

/// Only when system is 32 bits, call long or double native method will save as a pointer.
/// Pointer will free in Dart side.
#define CALL_IN_32_NATIVE_METHOD(name, ctype) \
    void *Call##name##In32Method(JNIEnv *env, jobject object, \
                            jmethodID methodId, jvalue *arguments) { \
        auto *ret = (ctype *)malloc(sizeof(ctype)); \
        auto nativeRet = env->Call##name##MethodA(object, methodId, arguments); \
        *ret = nativeRet; \
        return ret; \
    }

/// Only use in 32 bits system.
CALL_IN_32_NATIVE_METHOD(Long, int64_t)
CALL_IN_32_NATIVE_METHOD(Double, double)

/// Save pointer address as value.
#define CALL_INT_METHOD(name) \
    void *CallNative##name##Method(JNIEnv *env, jobject object, \
                            jmethodID methodId, jvalue *arguments) { \
        auto ret = env->Call##name##MethodA(object, methodId, arguments); \
        return (void *)ret; \
    }

CALL_INT_METHOD(Char)
CALL_INT_METHOD(Int)
CALL_INT_METHOD(Byte)
CALL_INT_METHOD(Short)
CALL_INT_METHOD(Boolean)
CALL_INT_METHOD(Long)

#define CALL_FLOAT_DOUBLE_METHOD(name, ctype) \
    void *CallNative##name##Method(JNIEnv *env, jobject object, \
                            jmethodID methodId, jvalue *arguments) { \
        void *ret; \
        auto nativeRet = env->Call##name##MethodA(object, methodId, arguments); \
        auto value = (ctype)nativeRet;        \
        memcpy(&ret, &value, sizeof(ctype)); \
        return ret; \
    }

CALL_FLOAT_DOUBLE_METHOD(Float, float)
CALL_FLOAT_DOUBLE_METHOD(Double, double)

void *CallNativeVoidMethod(JNIEnv *env,
                           jobject object,
                           jmethodID methodId,
                           jvalue *arguments) {
  env->CallVoidMethodA(object, methodId, arguments);
  return nullptr;
}

static const std::map<char, std::function<CallNativeMethod>> methodCallerMap = {
    {'C', CallNativeCharMethod},
    {'I', CallNativeIntMethod},
    {'D', IS_32_BITS ? CallDoubleIn32Method : CallNativeDoubleMethod},
    {'F', CallNativeFloatMethod},
    {'B', CallNativeByteMethod},
    {'S', CallNativeShortMethod},
    {'J', IS_32_BITS ? CallLongIn32Method : CallNativeLongMethod},
    {'Z', CallNativeBooleanMethod},
    {'V', CallNativeVoidMethod}};

std::map<char, std::function<CallNativeMethod>> GetMethodCallerMap() {
  return methodCallerMap;
}

void *callNativeStringMethod(JNIEnv *env,
                             jobject object,
                             jmethodID methodId,
                             jvalue *arguments) {
  auto javaString =
      (jstring) env->CallObjectMethodA(object, methodId, arguments);
  return ConvertToDartUtf16(env, javaString);
}

#define SET_ARG_VALUE(argValues, arguments, jtype, ctype, indexType, index) \
    argValues[index].indexType = (jtype) * (ctype *)(arguments); \
    if (sizeof(void *) == 4 && sizeof(ctype) > 4) { \
      (arguments)++; \
    }

void FillArgs2JValues(void **arguments,
                      char **argumentTypes,
                      jvalue *argValues,
                      int argumentCount,
                      uint32_t stringTypeBitmask,
                      JavaLocalRef<jobject> jObjBucket[]) {
  if (argumentCount == 0) {
    return;
  }

  JNIEnv *env = AttachCurrentThread();
  for (jsize index(0); index < argumentCount; ++arguments, ++index) {
    switch (*argumentTypes[index]) {
      case 'C':SET_ARG_VALUE(argValues, arguments, jchar, char, c, index)
        break;
      case 'I':SET_ARG_VALUE(argValues, arguments, jint, int, i, index)
        break;
      case 'D':SET_ARG_VALUE(argValues, arguments, jdouble, double, d, index)
        break;
      case 'F':SET_ARG_VALUE(argValues, arguments, jfloat, float, f, index)
        break;
      case 'B':SET_ARG_VALUE(argValues, arguments, jbyte, int8_t, b, index)
        break;
      case 'S':SET_ARG_VALUE(argValues, arguments, jshort, int16_t, s, index)
        break;
      case 'J':SET_ARG_VALUE(argValues, arguments, jlong, long long, j, index)
        break;
      case 'Z':argValues[index].z = static_cast<jboolean>(*((int *) arguments));
        break;
      default:
        /// when argument type is string or stringTypeBitmask mark as string
        if ((stringTypeBitmask >> index & 0x1) == 1) {
          JavaLocalRef<jobject> argString(ConvertToJavaUtf16(env, *arguments), env);
          jObjBucket[index] = argString;
          argValues[index].l = jObjBucket[index].Object();
        } else {
          /// convert from object cache
          /// check callback cache, if true using proxy object
          jobject object = getNativeCallbackProxyObject(*arguments);
          argValues[index].l =
              object == nullptr ? static_cast<jobject>(*arguments) : object;
        }
        break;
    }
  }
}

jstring ConvertToJavaUtf16(JNIEnv *env, void *value) {
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
uint16_t *ConvertToDartUtf16(JNIEnv *env, jstring nativeString) {
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
      env->DeleteLocalRef(nativeString);
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
  env->DeleteLocalRef(nativeString);
  return utf16Str;
}

}