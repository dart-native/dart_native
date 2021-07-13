//
// Created by Hui on 5/27/21.
//
#ifndef DART_NATIVE_DN_TYPE_CONVERT_H
#define DART_NATIVE_DN_TYPE_CONVERT_H

#include <stdint.h>
#include <jni.h>
#include <map>

#ifdef __cplusplus
extern "C"
{
#endif

  typedef void BasicTypeToNative(void *, jvalue *, int);

  jstring convertToJavaUtf16(JNIEnv *env, void *value, jvalue *argValue, int index);
  uint16_t *convertToDartUtf16(JNIEnv *env, jstring nativeString);

  void convertToJChar(void *value, jvalue *argValue, int index);
  void convertToJInt(void *value, jvalue *argValue, int index);
  void convertToJDouble(void *value, jvalue *argValue, int index);
  void convertToJFloat(void *value, jvalue *argValue, int index);
  void convertToJByte(void *value, jvalue *argValue, int index);
  void convertToJShort(void *value, jvalue *argValue, int index);
  void convertToJLong(void *value, jvalue *argValue, int index);
  void convertToJBoolean(void *value, jvalue *argValue, int index);

  /// key is basic argument signature
  const std::map<char, std::function<BasicTypeToNative> > basicTypeConvertMap = {
      {'C', convertToJChar},
      {'I', convertToJInt},
      {'D', convertToJDouble},
      {'F', convertToJFloat},
      {'B', convertToJByte},
      {'S', convertToJShort},
      {'J', convertToJLong},
      {'Z', convertToJBoolean}};

#ifdef __cplusplus
}
#endif
#endif //DART_NATIVE_DN_TYPE_CONVERT_H
