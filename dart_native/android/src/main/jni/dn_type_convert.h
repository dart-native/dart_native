//
// Created by Hui on 5/27/21.
//
#include <stdint.h>
#include <jni.h>
#include <map>
#include <string>

#ifndef DART_NATIVE_DN_TYPE_CONVERT_H
#define DART_NATIVE_DN_TYPE_CONVERT_H
#ifdef __cplusplus
extern "C"
{
#endif

typedef void ConvertToNative(void *, jvalue *, int);

  jstring convertToJavaUtf16(JNIEnv *env, void *value, jvalue *argValue, int index);

  void convertToJChar(void *value, jvalue *argValue, int index);
  void convertToJInt(void *value, jvalue *argValue, int index);
  void convertToJDouble(void *value, jvalue *argValue, int index);
  void convertToJFloat(void *value, jvalue *argValue, int index);
  void convertToJByte(void *value, jvalue *argValue, int index);
  void convertToJShort(void *value, jvalue *argValue, int index);
  void convertToJLong(void *value, jvalue *argValue, int index);
  void convertToJBoolean(void *value, jvalue *argValue, int index);

  const std::map<char, std::function<ConvertToNative>> typeConvertMap = {
      {'C', convertToJChar},
      {'I', convertToJInt},
      {'D', convertToJDouble},
      {'F', convertToJFloat},
      {'B', convertToJByte},
      {'S', convertToJShort},
      {'J', convertToJLong},
      {'Z', convertToJBoolean}};

  uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString);

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_TYPE_CONVERT_H
