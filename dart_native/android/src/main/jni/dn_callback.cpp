//
// Created by Hui on 6/1/21.
//
#include <string>
#include "dn_callback.h"
#include "dn_log.h"

static std::map<jlong, void *> targetCache;
static std::map<jlong, int64_t> dartPortCache;
static std::map<void *, jobject> callbackObjCache;
static std::map<jlong, std::map<std::string, NativeMethodCallback>> callbackManagerCache;

//void registerCallbackManager(jlong dartObjectAddress, char *functionName, void *callback)
//{
////  std::map<std::string, NativeMethodCallback> functionMap;
////
////  if (callbackManagerCache.find(dartObjectAddress) == callbackManagerCache.end())
////  {
////    DNDebug("callbackManagerCache not contain %d", dartObjectAddress);
////    functionMap[functionName] = (NativeMethodCallback) callback;
////    callbackManagerCache[dartObjectAddress] = functionMap;
////    return;
////  }
////
////  functionMap = callbackManagerCache[dartObjectAddress];
////  functionMap[functionName] = (NativeMethodCallback) callback;
////  callbackManagerCache[dartObjectAddress] = functionMap;
//}

void registerCallbackManager(jlong targetAddr, char *functionName, void *callback)
{
  std::map<std::string, NativeMethodCallback> methodsMap;
  if (!callbackManagerCache.count(targetAddr))
  {
    methodsMap[functionName] = (NativeMethodCallback)callback;
    callbackManagerCache[targetAddr] = methodsMap;
    return;
  }

  methodsMap = callbackManagerCache[targetAddr];
  methodsMap[functionName] = (NativeMethodCallback)callback;
  callbackManagerCache[targetAddr] = methodsMap;
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
    return nullptr;
  }

  return callbackObjCache[dartObject];
}

Dart_Port getCallbackDartPort(jlong dartObjectAddress)
{
  if (dartPortCache.find(dartObjectAddress) == dartPortCache.end())
  {
    return 0;
  }

  return dartPortCache[dartObjectAddress];
}

void *getDartObject(jlong dartObjectAddress)
{
  if (targetCache.find(dartObjectAddress) == targetCache.end())
  {
    return nullptr;
  }

  return targetCache[dartObjectAddress];
}

NativeMethodCallback getCallbackMethod(jlong targetAddr, char *functionName)
{
  if (!callbackManagerCache.count(targetAddr))
  {
    DNDebug("getCallbackMethod error not register %s", functionName);
    return NULL;
  }
  std::map<std::string, NativeMethodCallback> methodsMap = callbackManagerCache[targetAddr];
  return methodsMap[functionName];
}