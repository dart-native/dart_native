//
// Created by Hui on 6/1/21.
//
#include <string>
#include "dn_callback.h"
#include "dn_log.h"
#include "dn_type_convert.h"

static std::map<jlong, void *> targetCache;
static std::map<jlong, int64_t> dartPortCache;
static std::map<void *, jobject> callbackObjCache;
static std::map<jlong, std::map<std::string, NativeMethodCallback>> callbackFunctionCache;

void registerCallbackManager(jlong dartObjectAddress, char *functionName, void *callback)
{
  std::map<std::string, NativeMethodCallback> functionMap;

  if (callbackFunctionCache.find(dartObjectAddress) == callbackFunctionCache.end())
  {
    DNInfo("registerCallbackManager: callbackFunctionCache not contain this dart object %d", dartObjectAddress);
    functionMap[functionName] = (NativeMethodCallback) callback;
    callbackFunctionCache[dartObjectAddress] = functionMap;
    return;
  }

  functionMap = callbackFunctionCache[dartObjectAddress];
  functionMap[functionName] = (NativeMethodCallback) callback;
  callbackFunctionCache[dartObjectAddress] = functionMap;
}

void doRegisterNativeCallback(void *dartObject, jobject nativeProxyObject, char *funName, void *callback, Dart_Port dartPort)
{
  auto dartObjectAddress = (jlong) dartObject;
  callbackObjCache[dartObject] = nativeProxyObject;
  targetCache[dartObjectAddress] = dartObject;
  dartPortCache[dartObjectAddress] = dartPort;

  registerCallbackManager(dartObjectAddress, funName, callback);
}

jobject getNativeCallbackProxyObject(void *dartObject)
{
  if (callbackObjCache.find(dartObject) == callbackObjCache.end())
  {
    DNInfo("getNativeCallbackProxyObject: not contain this dart object");
    return nullptr;
  }

  return callbackObjCache[dartObject];
}

Dart_Port getCallbackDartPort(jlong dartObjectAddress)
{
  if (dartPortCache.find(dartObjectAddress) == dartPortCache.end())
  {
    DNInfo("getCallbackDartPort: dartPortCache not contain this dart object %d", dartObjectAddress);
    return 0;
  }

  return dartPortCache[dartObjectAddress];
}

void *getDartObject(jlong dartObjectAddress)
{
  if (targetCache.find(dartObjectAddress) == targetCache.end())
  {
    DNInfo("getDartObject: targetCache not contain this dart object %d", dartObjectAddress);
    return nullptr;
  }

  return targetCache[dartObjectAddress];
}

NativeMethodCallback getCallbackMethod(jlong dartObjectAddress, char *functionName)
{
  if (!callbackFunctionCache.count(dartObjectAddress))
  {
    DNInfo("getCallbackMethod: callbackFunctionCache not contain this dart object %d", dartObjectAddress);
    return nullptr;
  }
  std::map<std::string, NativeMethodCallback> methodsMap = callbackFunctionCache[dartObjectAddress];
  return methodsMap[functionName];
}

