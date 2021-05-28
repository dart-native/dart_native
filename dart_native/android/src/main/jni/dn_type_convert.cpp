//
// Created by Hui on 5/27/21.
//
#include <malloc.h>
#include <string>
#include "dn_type_convert.h"
#include "dn_log.h"

jstring convertToJavaUtf16(JNIEnv *env, void *value)
{
  uint16_t *utf16 = (uint16_t *)value;

  uint32_t length = 0;
  length += *utf16++ << 16;
  length += *utf16++;

  jstring nativeString = env->NewString(utf16, length);
  free(value);
  return nativeString;
}

uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString)
{
  const jchar *jc = env->GetStringChars(nativeString, NULL);
  jsize strLength = env->GetStringLength(nativeString);

  uint16_t *utf16Str = new uint16_t[strLength + 3];
  utf16Str[0] = strLength >> 16 & 0xFFFF;
  utf16Str[1] = strLength & 0xFFFF;

  for (int i = 0; i < strLength; i++)
  {
    utf16Str[i + 2] = jc[i];
  }
  utf16Str[strLength + 2] = '\0';

  env->ReleaseStringChars(nativeString, jc);
  env->DeleteLocalRef(nativeString);
  return utf16Str;
}
