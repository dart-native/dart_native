//
// Created by Hui on 5/31/21.
//
#include "dn_method_helper.h"
#include "dn_log.h"
#include "dn_callback.h"

namespace dartnative {

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

/// Returns a malloc pointer to the result.
char *GenerateSignature(char **argumentTypes, int argumentCount, char *returnType) {
  /// include "(" ")" length
  size_t signatureLength = strlen(returnType) + 2;
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

  return signature;
}

}