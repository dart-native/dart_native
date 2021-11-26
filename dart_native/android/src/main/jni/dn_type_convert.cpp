//
// Created by Hui on 5/27/21.
//
#include <malloc.h>
#include <string>
#include "dn_type_convert.h"
#include "dn_log.h"

#define SET_JAVA_VALUE(jtype, ctype, indexType) \
  bool Set##jtype##Value(void *value, jvalue *argValue, int index) { \
    argValue[index].indexType = (jtype) * (ctype *)value; \
    return sizeof(void *) == 4 && sizeof(ctype) > 4; \
  }

SET_JAVA_VALUE(jint, int, i)
SET_JAVA_VALUE(jchar, char, c)
SET_JAVA_VALUE(jbyte, int8_t, b)
SET_JAVA_VALUE(jshort, int16_t, s)
SET_JAVA_VALUE(jlong, long long, j)
SET_JAVA_VALUE(jfloat, float, f)
SET_JAVA_VALUE(jdouble, double, d)

bool convertToJBoolean(void *value, jvalue *argValue, int index) {
  argValue[index].z = static_cast<jboolean>(*((int *) value));
  return false;
}

/// key is basic argument signature
static const std::map<char, std::function<BasicTypeToNative>>
    basicTypeConvertMap = {
    {'C', SetjcharValue},
    {'I', SetjintValue},
    {'D', SetjdoubleValue},
    {'F', SetjfloatValue},
    {'B', SetjbyteValue},
    {'S', SetjshortValue},
    {'J', SetjlongValue},
    {'Z', convertToJBoolean}};


std::map<char, std::function<BasicTypeToNative>> GetTypeConvertMap() {
  return basicTypeConvertMap;
}

jstring convertToJavaUtf16(JNIEnv *env, void *value) {
  if (value == nullptr) {
    return nullptr;
  }
  auto *utf16 = (uint16_t *) value;

  uint32_t length = 0;
  length += *utf16++ << 16;
  length += *utf16++;

  auto nativeString = env->NewString(utf16, length);
  free(value);

  return nativeString;
}

/// nativeString not null
uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString) {
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
