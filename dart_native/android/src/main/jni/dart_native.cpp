#include <jni.h>
#include <map>
#include <string>
#include <semaphore.h>
#include "dn_log.h"
#include "dn_method_helper.h"
#include "dn_callback.h"
#include "jni_object_ref.h"
#include "dn_method.h"
#include "dn_jni_helper.h"
#include "dn_lifecycle_manager.h"
#include "dn_dart_api.h"

extern "C" {

using namespace dartnative;

static JavaGlobalRef<jobject> *gInterfaceRegistry = nullptr;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
  DNDebug("JNI_OnLoad");
  /// cache the JavaVM pointer
  InitWithJavaVM(pjvm);
  InitClazz();
  DNDebug("JNI_OnLoad finish");
  return JNI_VERSION_1_6;
}

void *getClassName(void *objectPtr) {
  if (objectPtr == nullptr) {
    return nullptr;
  }
  auto env = AttachCurrentThread();
  auto cls = FindClass("java/lang/Class", env);
  jmethodID getName = env->GetMethodID(cls, "getName", "()Ljava/lang/String;");
  auto object = static_cast<jobject>(objectPtr);
  auto objCls = env->GetObjectClass(object);
  auto jstr = (jstring) env->CallObjectMethod(objCls, getName);
  uint16_t *clsName = ConvertToDartUtf16(env, jstr);

  env->DeleteLocalRef(cls);
  env->DeleteLocalRef(objCls);
  return clsName;
}

jobject _newObject(jclass cls,
                   void **arguments,
                   char **argumentTypes,
                   int argumentCount,
                   uint32_t stringTypeBitmask) {
  auto *argValues = new jvalue[argumentCount];
  JavaLocalRef<jobject> jObjBucket[argumentCount];
  JNIEnv *env = AttachCurrentThread();
  FillArgs2JValues(arguments,
                   argumentTypes,
                   argValues,
                   argumentCount,
                   stringTypeBitmask,
                   jObjBucket);

  char *constructorSignature =
      GenerateSignature(argumentTypes, argumentCount, const_cast<char *>("V"));
  jmethodID constructor = env->GetMethodID(cls, "<init>", constructorSignature);
  jobject newObj = env->NewObjectA(cls, constructor, argValues);

//  _deleteArgs(argValues, argumentCount, stringTypeBitmask);
  free(constructorSignature);
  return newObj;
}

/// create target object
void *createTargetObject(char *targetClassName,
                         void **arguments,
                         char **argumentTypes,
                         int argumentCount,
                         uint32_t stringTypeBitmask) {
  JNIEnv *env = AttachCurrentThread();
  jclass cls = FindClass(targetClassName, env);
  jobject newObj = _newObject(cls,
                              arguments,
                              argumentTypes,
                              argumentCount,
                              stringTypeBitmask);
  jobject gObj = env->NewGlobalRef(newObj);
//  _addGlobalObject(gObj);

  env->DeleteLocalRef(newObj);
  env->DeleteLocalRef(cls);
  return gObj;
}

void *interfaceHostObjectWithName(char *name) {
  auto env = AttachCurrentThread();
  auto registryClz =
      FindClass("com/dartnative/dart_native/InterfaceRegistry", env);
  if (gInterfaceRegistry == nullptr) {
    auto instanceID =
        env->GetStaticMethodID(registryClz,
                               "getInstance",
                               "()Lcom/dartnative/dart_native/InterfaceRegistry;");
    auto registryObj = env->CallStaticObjectMethod(registryClz, instanceID);
    gInterfaceRegistry = new JavaGlobalRef<jobject>(registryObj, env);
    env->DeleteLocalRef(registryObj);
  }

  auto getInterface =
      env->GetMethodID(registryClz, "getInterface", "(Ljava/lang/String;)Ljava/lang/Object;");
  auto interfaceName = env->NewStringUTF(name);
  auto interface = env->CallObjectMethod(gInterfaceRegistry->Object(), getInterface, interfaceName);
  env->DeleteLocalRef(interfaceName);
  env->DeleteLocalRef(registryClz);
  return interface;
}

void *interfaceAllMetaData(char *name) {
  auto env = AttachCurrentThread();
  auto registryClz =
      FindClass("com/dartnative/dart_native/InterfaceRegistry", env);
  auto getSignatures =
      env->GetMethodID(registryClz, "getMethodsSignature", "(Ljava/lang/String;)Ljava/lang/String;");
  auto interfaceName = env->NewStringUTF(name);
  auto signatures = env->CallObjectMethod(gInterfaceRegistry->Object(), getSignatures, interfaceName);
  env->DeleteLocalRef(interfaceName);
  env->DeleteLocalRef(registryClz);
  return ConvertToDartUtf16(env, (jstring) signatures);
}

/// dart notify run callback function
void ExecuteCallback(DartWorkFunction *work_ptr) {
  const DartWorkFunction work = *work_ptr;
  work();
  delete work_ptr;
}

/// invoke native method
void *invokeNativeMethod(void *objPtr,
                         char *methodName,
                         void **arguments,
                         char **dataTypes,
                         int argumentCount,
                         char *returnType,
                         uint32_t stringTypeBitmask,
                         void *callback,
                         Dart_Port dartPort,
                         int thread,
                         bool isInterface) {
  dartnative::DNMethod
      method(objPtr, methodName, dataTypes, returnType, argumentCount, dartPort, callback);

  return method.InvokeNativeMethod(arguments, stringTypeBitmask, thread, isInterface);
}

/// register listener object by using java dynamic proxy
void registerNativeCallback(void *dartObject,
                            char *clsName,
                            char *funName,
                            void *callback,
                            Dart_Port dartPort) {
  JNIEnv *env = AttachCurrentThread();
  jclass callbackManager =
      FindClass("com/dartnative/dart_native/CallbackManager", env);
  jmethodID registerCallback = env->GetStaticMethodID(callbackManager,
                                                      "registerCallback",
                                                      "(JLjava/lang/String;)Ljava/lang/Object;");

  auto dartObjectAddress = (jlong) dartObject;
  /// create interface object using java dynamic proxy
  jstring newClsName = env->NewStringUTF(clsName);
  jobject proxyObject = env->CallStaticObjectMethod(callbackManager,
                                                    registerCallback,
                                                    dartObjectAddress,
                                                    newClsName);
  env->DeleteLocalRef(newClsName);
  jobject gProxyObj = env->NewGlobalRef(proxyObject);

  /// save object into cache
  doRegisterNativeCallback(dartObject, gProxyObj, funName, callback, dartPort);
  env->DeleteLocalRef(callbackManager);
  env->DeleteLocalRef(proxyObject);
}

/// init dart extensions
intptr_t InitDartApiDL(void *data) {
  return Dart_InitializeApiDL(data);
}

/// release native object from cache
static void RunFinalizer(void *isolate_callback_data,
                         void *peer) {
  ReleaseJObject(static_cast<jobject>(peer));
}

/// retain native object
void PassObjectToCUseDynamicLinking(Dart_Handle h, void *objPtr) {
  if (Dart_IsError_DL(h)) {
    DNError("Dart_IsError_DL");
    return;
  }
  RetainJObject(static_cast<jobject>(objPtr));
  intptr_t size = 8;
  Dart_NewWeakPersistentHandle_DL(h, objPtr, size, RunFinalizer);
}

JNIEXPORT jobject JNICALL
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
    auto argTypeString = (jstring) env->GetObjectArrayElement(argumentTypes, i);
    auto argument = env->GetObjectArrayElement(argumentsArray, i);
    dataTypes[i] = (char *) env->GetStringUTFChars(argTypeString, 0);
    if (strcmp(dataTypes[i], "java.lang.String") == 0) {
      /// argument will delete in ConvertToDartUtf16
      arguments[i] = ConvertToDartUtf16(env, (jstring) argument);
    } else {
      jobject gObj = env->NewGlobalRef(argument);
//      _addGlobalObject(gObj);
      arguments[i] = gObj;
      env->DeleteLocalRef(argument);
    }

    env->DeleteLocalRef(argTypeString);
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
  jobject callbackResult = nullptr;

  if (IsCurrentThread(dartObjectAddress, std::this_thread::get_id())) {
    DNDebug("callback with same thread");
    if (methodCallback != nullptr && target != nullptr) {
      methodCallback(target, funName, arguments, dataTypes, argumentCount);
    } else {
      arguments[argumentCount] = nullptr;
    }
  } else {
    DNDebug("callback with different thread");
    sem_t sem;
    bool isSemInitSuccess = sem_init(&sem, 0, 0) == 0;
    const DartWorkFunction work =
        [target, dataTypes, arguments, argumentCount, funName, &sem, isSemInitSuccess, methodCallback]() {
          if (methodCallback != nullptr && target != nullptr) {
            methodCallback(target, funName, arguments, dataTypes, argumentCount);
          } else {
            arguments[argumentCount] = nullptr;
          }
          if (isSemInitSuccess) {
            sem_post(&sem);
          }
        };

    const DartWorkFunction *work_ptr = new DartWorkFunction(work);
    /// check run result
    bool notifyResult = Notify2Dart(port, work_ptr);
    if (notifyResult) {
      if (isSemInitSuccess) {
        sem_wait(&sem);
        sem_destroy(&sem);
      }
    }
  }

  if (returnType == nullptr || strcmp(returnType, "void") == 0) {
    DNDebug("Native callback to Dart return type is void");
  } else if (strcmp(returnType, "java.lang.String") == 0) {
    callbackResult =
        ConvertToJavaUtf16(env, (char *) arguments[argumentCount]);
  } else {
    callbackResult = (jobject) arguments[argumentCount];
  }

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
}
