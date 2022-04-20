//
// Created by Hui on 6/1/21.
//
#include <string>
#include <semaphore.h>
#include "jni_object_ref.h"
#include "dn_jni_utils.h"
#include "dn_dart_api.h"
#include "dn_callback.h"
#include "dn_log.h"

namespace dartnative {

/// key is dart object pointer address, value is dart port
static std::map<jlong, int64_t> dartPortCache;
/// key is dart object pointer, value is native proxy object
static std::map<void *, jobject> nativeProxyObjectCache;
/// key is dart object pointer address, value is method
static std::map<jlong, std::map<std::string, NativeMethodCallback>>
    callbackFunctionCache;
/// key is dart object pointer address, value is thread id
static std::map<jlong, std::__thread_id> threadIdCache;

void registerCallbackManager(jlong dartObjectAddress,
                             char *functionName,
                             void *callback) {
  std::map<std::string, NativeMethodCallback> functionMap;

  if (callbackFunctionCache.find(dartObjectAddress)
      == callbackFunctionCache.end()) {
    DNInfo(
        "registerCallbackManager: callbackFunctionCache not contain this dart object %d",
        dartObjectAddress);
    functionMap[functionName] = (NativeMethodCallback) callback;
    callbackFunctionCache[dartObjectAddress] = functionMap;
    return;
  }

  functionMap = callbackFunctionCache[dartObjectAddress];
  functionMap[functionName] = (NativeMethodCallback) callback;
  callbackFunctionCache[dartObjectAddress] = functionMap;
}

void doRegisterNativeCallback(void *dartObject,
                              jobject nativeProxyObject,
                              char *funName,
                              void *callback,
                              Dart_Port dartPort) {
  auto dartObjectAddress = (jlong) dartObject;
  nativeProxyObjectCache[dartObject] = nativeProxyObject;
  dartPortCache[dartObjectAddress] = dartPort;
  threadIdCache[dartObjectAddress] = std::this_thread::get_id();

  registerCallbackManager(dartObjectAddress, funName, callback);
}

jobject getNativeCallbackProxyObject(void *dartObject) {
  if (nativeProxyObjectCache.find(dartObject) == nativeProxyObjectCache.end()) {
    DNInfo("getNativeCallbackProxyObject: not contain this dart object");
    return nullptr;
  }

  return nativeProxyObjectCache[dartObject];
}

Dart_Port getCallbackDartPort(jlong dartObjectAddress) {
  if (dartPortCache.find(dartObjectAddress) == dartPortCache.end()) {
    DNInfo("getCallbackDartPort: dartPortCache not contain this dart object %d",
           dartObjectAddress);
    return 0;
  }

  return dartPortCache[dartObjectAddress];
}

NativeMethodCallback
getCallbackMethod(jlong dartObjectAddress, char *functionName) {
  if (!callbackFunctionCache.count(dartObjectAddress)) {
    DNInfo(
        "getCallbackMethod: callbackFunctionCache not contain this dart object %d",
        dartObjectAddress);
    return nullptr;
  }
  std::map<std::string, NativeMethodCallback>
      methodsMap = callbackFunctionCache[dartObjectAddress];
  return methodsMap[functionName];
}

bool IsCurrentThread(jlong dartObjectAddress, std::__thread_id currentThread) {
  if (!threadIdCache.count(dartObjectAddress)) {
    DNInfo(
        "IsCurrentThread: threadIdCache not contain this dart object %d",
        dartObjectAddress);
    return false;
  }
  return threadIdCache[dartObjectAddress] == currentThread;
}

extern "C" JNIEXPORT jobject JNICALL
Java_com_dartnative_dart_1native_CallbackInvocationHandler_hookCallback(JNIEnv *env,
                                                                        jclass clazz,
                                                                        jlong dartObjectAddress,
                                                                        jstring functionName,
                                                                        jint argumentCount,
                                                                        jobjectArray argumentTypes,
                                                                        jobjectArray argumentsArray,
                                                                        jstring returnTypeStr) {
  Dart_Port port = getCallbackDartPort(dartObjectAddress);
  if (port == 0) {
    DNError("not register this dart port!");
    return nullptr;
  }

  char *funName = functionName == nullptr ? nullptr
                                          : (char *) env->GetStringUTFChars(
          functionName,
          nullptr);
  char **dataTypes = new char *[argumentCount + 1];
  void **arguments = new void *[argumentCount + 1];

  /// store argument to pointer
  for (int i = 0; i < argumentCount; ++i) {
    JavaLocalRef<jstring>
        argTypeString((jstring) env->GetObjectArrayElement(argumentTypes, i), env);
    JavaLocalRef<jobject> argument(env->GetObjectArrayElement(argumentsArray, i), env);
    dataTypes[i] = (char *) env->GetStringUTFChars(argTypeString.Object(), 0);
    if (strcmp(dataTypes[i], "java.lang.String") == 0) {
      /// argument will delete in JavaStringToDartString
      arguments[i] = JavaStringToDartString(env, (jstring) argument.Object());
    } else {
      jobject gObj = env->NewGlobalRef(argument.Object());
      arguments[i] = gObj;
    }
  }

  /// when return void, jstring which from native is null.
  char *returnType = returnTypeStr == nullptr ? nullptr
                                              : (char *) env->GetStringUTFChars(
          returnTypeStr,
          nullptr);
  /// the last pointer is return type
  dataTypes[argumentCount] = returnType;

  NativeMethodCallback
      methodCallback = getCallbackMethod(dartObjectAddress, funName);
  void *target = (void *) dartObjectAddress;
  jobject callbackResult =
      InvokeDartFunction(IsCurrentThread(dartObjectAddress, std::this_thread::get_id()),
                         methodCallback,
                         target,
                         funName,
                         arguments,
                         dataTypes,
                         argumentCount,
                         returnType,
                         port,
                         env);

  if (returnTypeStr != nullptr) {
    env->ReleaseStringUTFChars(returnTypeStr, returnType);
  }
  if (functionName != nullptr) {
    env->ReleaseStringUTFChars(functionName, funName);
  }
  delete[] arguments;
  delete[] dataTypes;

  return callbackResult;
}

jobject InvokeDartFunction(bool is_same_thread,
                           NativeMethodCallback method_callback,
                           void *target,
                           char *funName,
                           void **arguments,
                           char **dataTypes,
                           int argumentCount,
                           char *return_type,
                           Dart_Port port,
                           JNIEnv *env) {
  jobject callbackResult = nullptr;
  if (is_same_thread) {
    if (method_callback != nullptr && target != nullptr) {
      method_callback(target, funName, arguments, dataTypes, argumentCount);
    } else {
      arguments[argumentCount] = nullptr;
    }
  } else {
    sem_t sem;
    bool isSemInitSuccess = sem_init(&sem, 0, 0) == 0;
    const WorkFunction work =
        [target, dataTypes, arguments, argumentCount, funName, &sem, isSemInitSuccess, method_callback]() {
          if (method_callback != nullptr && target != nullptr) {
            method_callback(target, funName, arguments, dataTypes, argumentCount);
          } else {
            arguments[argumentCount] = nullptr;
          }
          if (isSemInitSuccess) {
            sem_post(&sem);
          }
        };

    const WorkFunction *work_ptr = new WorkFunction(work);
    /// check run result
    bool notifyResult = Notify2Dart(port, work_ptr);
    if (notifyResult) {
      if (isSemInitSuccess) {
        sem_wait(&sem);
        sem_destroy(&sem);
      }
    }
  }

  if(arguments[argumentCount] == nullptr) {
    return nullptr;
  }

  if (return_type == nullptr || strcmp(return_type, "void") == 0) {
    return nullptr;
  } else if (strcmp(return_type, "java.lang.String") == 0) {
    callbackResult =
        DartStringToJavaString(env, (char *) arguments[argumentCount]);
  } else {
    callbackResult = (jobject) arguments[argumentCount];
  }
  return callbackResult;
}
}
