//
// Created by Hui on 6/1/21.
//
#include <string>
#include <semaphore.h>
#include <dart_native_api.h>
#include <dart_api_dl.h>
#include "dn_callback.h"
#include "dn_log.h"

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

bool NotifyDart(Dart_Port send_port, const Work *work)
{
  const auto work_addr = reinterpret_cast<intptr_t>(work);

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = work_addr;

  const bool result = Dart_PostCObject_DL(send_port, &dart_object);
  if (!result)
  {
    DNDebug("Native callback to Dart failed! Invalid port or isolate died");
  }
  return result;
}

extern "C" JNIEXPORT jobject JNICALL Java_com_dartnative_dart_1native_CallbackInvocationHandler_hookCallback(JNIEnv *env,
                                                                                                  jclass clazz,
                                                                                                  jlong dartObjectAddress,
                                                                                                  jstring functionName,
                                                                                                  jint argumentCount,
                                                                                                  jobjectArray argumentTypes,
                                                                                                  jobjectArray argumentsArray,
                                                                                                  jstring returnTypeStr)
{
  Dart_Port port = getCallbackDartPort(dartObjectAddress);
  if (port == 0)
  {
    DNDebug("not register dart port!");
    return nullptr;
  }

  char *funName = (char *)env->GetStringUTFChars(functionName, 0);
  char **argTypes = new char *[argumentCount + 1];
  void **arguments = new void *[argumentCount];
  for (int i = 0; i < argumentCount; ++i)
  {
    jstring argTypeString = (jstring)env->GetObjectArrayElement(argumentTypes, i);
    jobject argument = env->GetObjectArrayElement(argumentsArray, i);

    argTypes[i] = (char *)env->GetStringUTFChars(argTypeString, 0);
    env->DeleteLocalRef(argTypeString);
    //todo optimization
    if (strcmp(argTypes[i], "I") == 0)
    {
      jclass cls = env->FindClass("java/lang/Integer");
      if (env->IsInstanceOf(argument, cls) == JNI_TRUE)
      {
        jmethodID integerToInt = env->GetMethodID(cls, "intValue", "()I");
        jint result = env->CallIntMethod(argument, integerToInt);
        arguments[i] = (void *)result;
      }
      env->DeleteLocalRef(cls);
    }
    else if (strcmp(argTypes[i], "F") == 0)
    {
      jclass cls = env->FindClass("java/lang/Float");
      if (env->IsInstanceOf(argument, cls) == JNI_TRUE)
      {
        jmethodID toJfloat = env->GetMethodID(cls, "floatValue", "()F");
        jfloat result = env->CallFloatMethod(argument, toJfloat);
        float templeFloat = (float)result;
        memcpy(&arguments[i], &templeFloat, sizeof(float));
      }
      env->DeleteLocalRef(cls);
    }
    else if (strcmp(argTypes[i], "D") == 0)
    {
      jclass cls = env->FindClass("java/lang/Double");
      if (env->IsInstanceOf(argument, cls) == JNI_TRUE)
      {
        jmethodID toJfloat = env->GetMethodID(cls, "doubleValue", "()D");
        jdouble result = env->CallDoubleMethod(argument, toJfloat);
        double templeDouble = (double)result;
        memcpy(&arguments[i], &templeDouble, sizeof(double));
      }
      env->DeleteLocalRef(cls);
    }
    else if (strcmp(argTypes[i], "Ljava/lang/String;") == 0)
    {
      jstring argString = (jstring)argument;
      arguments[i] = argString == nullptr ? (char *)""
                                          : (char *)env->GetStringUTFChars(argString, 0);
      env->DeleteLocalRef(argString);
    }
  }

  /// when return void, jstring which from native is null.
  char *returnType = returnTypeStr == nullptr ? nullptr
                                            : (char *)env->GetStringUTFChars(returnTypeStr, 0);

  argTypes[argumentCount] = returnType;

  sem_t sem;
  bool isSemInitSuccess = sem_init(&sem, 0, 0) == 0;

  const Work work = [dartObjectAddress, argTypes, arguments, argumentCount, funName, &sem, isSemInitSuccess]() {
    NativeMethodCallback methodCallback = getCallbackMethod(dartObjectAddress, funName);
    void *target = getDartObject(dartObjectAddress);
    if (methodCallback != nullptr && target != nullptr)
    {
      methodCallback(target, funName, arguments, argTypes, argumentCount);
    }
    if (isSemInitSuccess)
    {
      sem_post(&sem);
    }
  };

  const Work *work_ptr = new Work(work);
  /// error
  bool notifyResult = NotifyDart(port, work_ptr);

  jobject callbackResult = nullptr;
  if (isSemInitSuccess)
  {
    DNDebug("wait work execute");
    sem_wait(&sem);
    //todo optimization
    if (returnType == nullptr)
    {
      DNDebug("void");
    }
    else if (strcmp(returnType, "Ljava/lang/String;") == 0)
    {
      callbackResult = env->NewStringUTF(arguments[0] == nullptr ? (char *)""
                                                                 : (char *)arguments[0]);
    }
    else if (strcmp(returnType, "Z") == 0)
    {
      jclass booleanClass = env->FindClass("java/lang/Boolean");
      jmethodID methodID = env->GetMethodID(booleanClass, "<init>", "(Z)V");
      callbackResult = env->NewObject(booleanClass,
                                      methodID,
                                      notifyResult ? static_cast<jboolean>(*((int *)arguments))
                                                   : JNI_FALSE);
      env->DeleteLocalRef(booleanClass);
    }
    sem_destroy(&sem);
  }

  free(returnType);
  free(funName);
  free(arguments);
  free(argTypes);

  return callbackResult;
}
