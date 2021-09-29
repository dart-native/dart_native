//
// Created by Hui on 5/27/21.
//
#include <malloc.h>
#include <string>
#include "dn_type_convert.h"
#include "dn_log.h"

jstring convertToJavaUtf16(JNIEnv *env, void *value)
{
  auto *utf16 = (uint16_t *)value;

  uint32_t length = 0;
  length += *utf16++ << 16;
  length += *utf16++;

  auto nativeString = env->NewString(utf16, length);
  free(value);

  return nativeString;
}

/// nativeString not null
uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString)
{
  const jchar *jc = env->GetStringChars(nativeString, nullptr);
  jsize strLength = env->GetStringLength(nativeString);

  /// check bom
  bool hasBom = jc[0] == 0xFEFF || jc[0] == 0xFFFE; // skip bom
  int indexStart = 0;
  if (hasBom)
  {
    strLength--;
    indexStart = 1;
    if (strLength <= 0)
    {
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
  for (int i = indexStart; i < strLength; i++)
  {
    utf16Str[u16Index++] = jc[i];
  }
  utf16Str[strLength + 2] = '\0';

  env->ReleaseStringChars(nativeString, jc);
  env->DeleteLocalRef(nativeString);
  return utf16Str;
}

void convertToJChar(void *value, jvalue *argValue, int index)
{
  argValue[index].c = (jchar) * (char *)value;
}

void convertToJInt(void *value, jvalue *argValue, int index)
{
  argValue[index].i = (jint) * (int *)value;
}

void convertToJDouble(void *value, jvalue *argValue, int index)
{
  argValue[index].d = (jdouble) * (double *)value;
}

void convertToJFloat(void *value, jvalue *argValue, int index)
{
  argValue[index].f = (jfloat) * (float *)value;
}

void convertToJByte(void *value, jvalue *argValue, int index)
{
  argValue[index].b = (jbyte) * (int8_t *)value;
}

void convertToJShort(void *value, jvalue *argValue, int index)
{
  argValue[index].s = (jshort) * (int16_t *)value;
}

void convertToJLong(void *value, jvalue *argValue, int index)
{
  argValue[index].j = (jlong) * (long long*)value;
}

void convertToJBoolean(void *value, jvalue *argValue, int index)
{
  argValue[index].z = static_cast<jboolean>(*((int *)value));
}
