//
// Created by Hui on 5/31/21.
//
#include <semaphore.h>
#include <dn_dart_api.h>
#include "dn_method_helper.h"
#include "dn_log.h"
#include "dn_callback.h"
#include "dn_jni_helper.h"

namespace dartnative {

#define SET_ARG_VALUE(argValues, arguments, jtype, ctype, indexType, index) \
    argValues[index].indexType = (jtype) * (ctype *)(arguments); \
    if (sizeof(void *) == 4 && sizeof(ctype) > 4) { \
      (arguments)++; \
    }

jvalue *ConvertArgs2JValues(void **arguments,
                            char **argumentTypes,
                            int argumentCount,
                            uint32_t stringTypeBitmask,
                            JavaLocalRef<jobject> jObjBucket[]) {
  auto *argValues = new jvalue[argumentCount];
  if (argumentCount == 0) {
    return argValues;
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
          JavaLocalRef<jobject> argString(DartStringToJavaString(env, *arguments), env);
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
  return argValues;
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

void *DoInvokeNativeMethod(jobject object,
                           char *methodName,
                           void **arguments,
                           char **typePointers,
                           int argumentCount,
                           char *returnType,
                           uint32_t stringTypeBitmask,
                           void *callback,
                           Dart_Port dartPort,
                           TaskThread thread) {
  void *nativeInvokeResult = nullptr;
  JNIEnv *env = AttachCurrentThread();
  JavaLocalRef<jclass> cls(env->GetObjectClass(object), env);

  JavaLocalRef<jobject> jObjBucket[argumentCount];
  auto *argValues = ConvertArgs2JValues(arguments,
                                        typePointers,
                                        argumentCount,
                                        stringTypeBitmask,
                                        jObjBucket);

  char *methodSignature =
      GenerateSignature(typePointers, argumentCount, returnType);
  jmethodID method = env->GetMethodID(cls.Object(), methodName, methodSignature);
  /// Save return type, dart will use this pointer.
  typePointers[argumentCount] = returnType;

  switch (*returnType) {
    case 'C':nativeInvokeResult = (void *) env->CallCharMethodA(object, method, argValues);
      break;
    case 'I':nativeInvokeResult = (void *) env->CallIntMethodA(object, method, argValues);
      break;
    case 'D': {
      if (sizeof(void *) == 4) {
        nativeInvokeResult = (double *) malloc(sizeof(double));
      }
      auto nativeRet = env->CallDoubleMethodA(object, method, argValues);
      memcpy(&nativeInvokeResult, &nativeRet, sizeof(double));
    }
      break;
    case 'F': {
      auto fret = env->CallFloatMethodA(object, method, argValues);
      auto fvalue = (float) fret;
      memcpy(&nativeInvokeResult, &fvalue, sizeof(float));
    }
      break;
    case 'B':nativeInvokeResult = (void *) env->CallByteMethodA(object, method, argValues);
      break;
    case 'S':nativeInvokeResult = (void *) env->CallShortMethodA(object, method, argValues);
      break;
    case 'J': {
      if (sizeof(void *) == 4) {
        nativeInvokeResult = (int64_t *) malloc(sizeof(int64_t));
      }
      nativeInvokeResult = (void *) env->CallLongMethodA(object, method, argValues);
    }
      break;
    case 'Z':nativeInvokeResult = (void *) env->CallBooleanMethodA(object, method, argValues);
      break;
    case 'V':env->CallVoidMethodA(object, method, argValues);
      break;
    default:
      if (strcmp(returnType, "Ljava/lang/String;") == 0) {
        typePointers[argumentCount] = (char *) "java.lang.String";
        JavaLocalRef<jstring> javaString((jstring) env->CallObjectMethodA(object, method, argValues), env);
        nativeInvokeResult = JavaStringToDartString(env, javaString.Object());
      } else {
        JavaLocalRef<jobject> obj(env->CallObjectMethodA(object, method, argValues), env);
        if (!obj.IsNull()) {
          if (env->IsInstanceOf(obj.Object(), GetStringClazz())) {
            /// mark the last pointer as string
            /// dart will check this pointer
            typePointers[argumentCount] = (char *) "java.lang.String";
            nativeInvokeResult = JavaStringToDartString(env, (jstring) obj.Object());
          } else {
            typePointers[argumentCount] = (char *) "java.lang.Object";
            jobject gObj = env->NewGlobalRef(obj.Object());
            nativeInvokeResult = gObj;
          }
        }
      }
      break;
  }

  if (callback != nullptr) {
    if (thread == TaskThread::kFlutterUI) {
      ((InvokeCallback) callback)(nativeInvokeResult,
                                  methodName,
                                  typePointers,
                                  argumentCount);
    } else {
      sem_t sem;
      bool isSemInitSuccess = sem_init(&sem, 0, 0) == 0;
      const WorkFunction work =
          [callback, nativeInvokeResult, methodName, typePointers, argumentCount, isSemInitSuccess, &sem] {
            ((InvokeCallback) callback)(nativeInvokeResult,
                                        methodName,
                                        typePointers,
                                        argumentCount);
            if (isSemInitSuccess) {
              sem_post(&sem);
            }
          };
      const WorkFunction *work_ptr = new WorkFunction(work);
      /// check run result
      bool notifyResult = Notify2Dart(dartPort, work_ptr);
      if (notifyResult) {
        if (isSemInitSuccess) {
          sem_wait(&sem);
          sem_destroy(&sem);
        }
      }
    }
  }

  free(methodName);
  free(returnType);
  free(arguments);
  free(methodSignature);
  delete[]argValues;
  return nativeInvokeResult;
}

}