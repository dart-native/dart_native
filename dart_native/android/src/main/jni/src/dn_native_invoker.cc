//
// Created by Hui on 5/31/21.
//
#include <semaphore.h>
#include <dn_dart_api.h>
#include <unordered_map>
#include "dn_native_invoker.h"
#include "dn_log.h"
#include "dn_callback.h"
#include "dn_jni_utils.h"

namespace dartnative {

JavaLocalRef<jclass> FindClass(const char *name, JNIEnv *env) {
  if (env == nullptr) {
    env = AttachCurrentThread();
  }
  JavaLocalRef<jclass> nativeClass(env->FindClass(name), env);
  /// class loader not found class
  if (ClearException(env)) {
    JavaLocalRef<jstring> clsName(env->NewStringUTF(name), env);
    JavaLocalRef<jclass>
        findedClass(static_cast<jclass>(env->CallObjectMethod(GetClassLoaderObj(),
                                                              GetFindClassMethod(),
                                                              clsName.Object())), env);
    if (ClearException(env)) {
      DNError("Find class error, can not find %s", name);
      JavaLocalRef<jclass> nullClz(nullptr, env);
      return nullClz;
    }
    return findedClass;
  }
  return nativeClass;
}

JavaLocalRef<jobject> NewObject(jclass cls,
                                void **arguments,
                                char **argumentTypes,
                                int argumentCount,
                                uint32_t stringTypeBitmask) {
  JavaLocalRef<jobject> jObjBucket[argumentCount];
  JNIEnv *env = AttachCurrentThread();
  auto values =
      ConvertArgs2JValues(arguments, argumentTypes, argumentCount, stringTypeBitmask, jObjBucket);

  char *constructorSignature =
      GenerateSignature(argumentTypes, argumentCount, const_cast<char *>("V"));
  jmethodID constructor = env->GetMethodID(cls, "<init>", constructorSignature);
  if (constructor == nullptr) {
    DNError("NewObject error, could not locate init method, signature: %s!", constructorSignature);
    free(constructorSignature);
    delete[] values;
    JavaLocalRef<jobject> nullObj(nullptr, env);
    return nullObj;
  }

  JavaLocalRef<jobject> newObj(env->NewObjectA(cls, constructor, values), env);
  if (ClearException(env)) {
    free(constructorSignature);
    delete[] values;
    DNError("NewObject error, call new object error!");
    JavaLocalRef<jobject> nullObj(nullptr, env);
    return nullObj;
  }

  free(constructorSignature);
  delete[] values;
  return newObj;
}

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
          jobject object = GetNativeCallbackProxyObject(*arguments);
          argValues[index].l =
              object == nullptr ? static_cast<jobject>(*arguments) : object;
        }
        break;
    }
  }
  return argValues;
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
  if (env == nullptr) {
    DNError("DoInvokeNativeMethod error, no JNIEnv provided!");
    free(methodName);
    free(returnType);
    free(arguments);
    return nullptr;
  }

  JavaLocalRef<jclass> cls(env->GetObjectClass(object), env);
  if (cls.IsNull()) {
    DNError("DoInvokeNativeMethod error, could not get class!");
    free(methodName);
    free(returnType);
    free(arguments);
    return nullptr;
  }

  JavaLocalRef<jobject> jObjBucket[argumentCount];
  auto *argValues = ConvertArgs2JValues(arguments,
                                        typePointers,
                                        argumentCount,
                                        stringTypeBitmask,
                                        jObjBucket);

  char *methodSignature =
      GenerateSignature(typePointers, argumentCount, returnType);
  jmethodID method = env->GetMethodID(cls.Object(), methodName, methodSignature);
  if (method == nullptr) {
    DNError("DoInvokeNativeMethod error, method is null, signature is %s#%s!",
            methodName, methodSignature);
    free(methodName);
    free(returnType);
    free(arguments);
    free(methodSignature);
    delete[] argValues;
    return nullptr;
  }
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

  if (ClearException(env)) {
    DNError("DoInvokeNativeMethod error, call native method error!");
    free(methodName);
    free(returnType);
    free(arguments);
    free(methodSignature);
    delete[] argValues;
    return nullptr;
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
  delete[] argValues;
  return nativeInvokeResult;
}

// When dart function is async invoke, save result callback.
static std::unordered_map<int64_t, std::function<void(jobject)>> g_async_callback_map;
// dart async invoke result response id
int64_t g_response_id = 0;
// g_async_callback_map lock
std::mutex g_async_map_mtx;

int64_t SetAsyncCallback(const std::function<void(jobject)>& callback) {
  std::lock_guard<std::mutex> lockGuard(g_async_map_mtx);
  g_response_id += 1;
  g_async_callback_map[g_response_id] = callback;
  return g_response_id;
}

std::function<void(jobject)> GetAsyncCallback(int64_t response) {
  std::lock_guard<std::mutex> lockGuard(g_async_map_mtx);
  auto it = g_async_callback_map.find(response);
  if (it == g_async_callback_map.end()) {
    return nullptr;
  }

  auto callback = it->second;
  g_async_callback_map.erase(it);
  return callback;
}

jobject InvokeDartFunction(bool is_same_thread,
                           int return_async,
                           NativeMethodCallback method_callback,
                           void *target,
                           char *method_name,
                           jobjectArray arguments,
                           jobjectArray argument_types,
                           int argument_count,
                           char *return_type,
                           Dart_Port port,
                           JNIEnv *env,
                           const std::function<void(jobject)>& async_callback) {
  bool isVoid = strcmp(return_type, "void") == 0;
  char **type_array = new char *[argument_count + 1];
  void **argument_array = new void *[argument_count + 1];

  // Store argument and type to pointer.
  for (int i = 0; i < argument_count; ++i) {
    JavaLocalRef<jstring>
        argTypeString((jstring) env->GetObjectArrayElement(argument_types, i), env);
    JavaLocalRef<jobject> argument(env->GetObjectArrayElement(arguments, i), env);
    type_array[i] = (char *) env->GetStringUTFChars(argTypeString.Object(), NULL);
    if (strcmp(type_array[i], "java.lang.String") == 0) {
      // Argument will delete in JavaStringToDartString。
      argument_array[i] = JavaStringToDartString(env, (jstring) argument.Object());
    } else {
      jobject gObj = env->NewGlobalRef(argument.Object());
      argument_array[i] = gObj;
    }
  }
  // The last pointer is invoke result.
  argument_array[argument_count] = nullptr;
  // The last pointer is return type.
  type_array[argument_count] = return_type;

  // Call dart function is same thread as java side.
  if (is_same_thread) {
    if (method_callback != nullptr && target != nullptr) {
      method_callback(target,
                      method_name,
                      argument_array,
                      type_array,
                      argument_count,
                      return_async,
                      0);
    } else {
      argument_array[argument_count] = nullptr;
    }
    auto ret = ConvertDartValue2JavaValue(return_type, argument_array[argument_count], env);
    async_callback(nullptr);
    delete[] argument_array;
    delete[] type_array;
    return ret;
  }

  // Hooping between the dart and the java thread.
  sem_t sem;
  bool isSemInitSuccess = false;
  if (!isVoid && !return_async) {
    isSemInitSuccess = sem_init(&sem, 0, 0) == 0;
  }
  const WorkFunction work = [=, &sem]() {
    if (method_callback != nullptr && target != nullptr) {
      int64_t response = SetAsyncCallback(async_callback);
      method_callback(target,
                      method_name,
                      argument_array,
                      type_array,
                      argument_count,
                      return_async,
                      response);

    } else {
      argument_array[argument_count] = nullptr;
    }

    if (isSemInitSuccess) {
      sem_post(&sem);
      return;
    }

    delete[] argument_array;
    delete[] type_array;
  };

  const WorkFunction *work_ptr = new WorkFunction(work);
  // Check notify result.
  bool notifyResult = Notify2Dart(port, work_ptr);
  if (notifyResult && isSemInitSuccess) {
    sem_wait(&sem);
    sem_destroy(&sem);
    // Invoke dart function success.
    auto ret =
        ConvertDartValue2JavaValue(type_array[argument_count], argument_array[argument_count], env);
    async_callback(ret);
    delete[] argument_array;
    delete[] type_array;
    return ret;
  }

  // If notify success, arrays will delete is work function.
  if (!notifyResult) {
    delete[] argument_array;
    delete[] type_array;
  }

  return nullptr;
}

jobject ConvertDartValue2JavaValue(char *return_type, void *dart_value, JNIEnv *env) {
  if (env == nullptr) {
    env = AttachCurrentThread();
  }

  if (dart_value == nullptr || return_type == nullptr) {
    return nullptr;
  }

  if (strcmp(return_type, "java.lang.String") == 0) {
    if (env == nullptr) {
      return nullptr;
    }
    return DartStringToJavaString(env, (char *) dart_value);
  } else {
    return (jobject) dart_value;
  }
}

void DartAsyncResult(int64_t response, void *result, char *type, JNIEnv *env) {
  auto invoker = GetAsyncCallback(response);
  if (invoker == nullptr) {
    DNError("AsyncResult error, not register async callback!");
    return;
  }

  auto ret = ConvertDartValue2JavaValue(type, result, env);
  invoker(ret);
}
}
