//
// Created by Hui on 5/27/21.
//
#include <malloc.h>
#include <string>
#include "dn_type_convert.h"
#include "dn_log.h"

jstring convertToJavaUtf16(JNIEnv *env, void *value, jvalue *argValue, int index)
{
  uint16_t *utf16 = (uint16_t *)value;

  uint32_t length = 0;
  length += *utf16++ << 16;
  length += *utf16++;

  jstring nativeString = env->NewString(utf16, length);
  free(value);

  if (argValue != nullptr)
  {
    argValue[index].l = nativeString;
  }
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
  argValue[index].j = (jlong) * (long *)value;
}

void convertToJBoolean(void *value, jvalue *argValue, int index)
{
  argValue[index].z = static_cast<jboolean>(*((int *)value));
}
