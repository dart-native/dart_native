//
// Created by Hui on 6/1/21.
//
#include <string>
#include <semaphore.h>
#include "dn_native_invoker.h"
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

  char *funName =
      functionName == nullptr ? nullptr : (char *) env->GetStringUTFChars(functionName, nullptr);
  // When return void, jstring which from native is null.
  char *returnType =
      returnTypeStr == nullptr ? nullptr : (char *) env->GetStringUTFChars(returnTypeStr, nullptr);

  NativeMethodCallback
      methodCallback = getCallbackMethod(dartObjectAddress, funName);
  void *target = (void *) dartObjectAddress;
  // release jstring
  auto clear_fun = [=](jobject) {
    auto clear_env = AttachCurrentThread();
    if (clear_env == nullptr) {
      DNError("Clear_env error, clear_env no JNIEnv provided!");
      return;
    }

    if (returnTypeStr != nullptr) {
      clear_env->ReleaseStringUTFChars(returnTypeStr, returnType);
    }

    if (functionName != nullptr) {
      clear_env->ReleaseStringUTFChars(functionName, funName);
    }
  };

  auto callbackResult =
      InvokeDartFunction(IsCurrentThread(dartObjectAddress, std::this_thread::get_id()),
                         0,
                         methodCallback,
                         target,
                         funName,
                         argumentsArray,
                         argumentsArray,
                         argumentCount,
                         returnType,
                         port,
                         env,
                         clear_fun);

  return callbackResult;
}

}
