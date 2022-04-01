//
// Created by Hui on 5/31/21.
//
#include "dn_method_call.h"
#include "dn_type_convert.h"
#include "dn_log.h"
#include "dn_callback.h"

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
    /// check basic map convert
    auto map = GetTypeConvertMap();
    auto it = map.find(*argumentTypes[index]);

    if (it == map.end()) {
      /// when argument type is string or stringTypeBitmask mark as string
      if ((stringTypeBitmask >> index & 0x1) == 1) {
        JavaLocalRef<jobject> argString(convertToJavaUtf16(env, *arguments), env);
        jObjBucket[index] = argString;
        argValues[index].l = jObjBucket[index].Object();
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
