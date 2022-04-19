#include <semaphore.h>
#include "dart_native.h"
#include "dn_thread.h"
#include "dn_log.h"
#include "dn_method_helper.h"
#include "dn_callback.h"
#include "jni_object_ref.h"
#include "dn_jni_helper.h"
#include "dn_lifecycle_manager.h"

using namespace dartnative;

static JavaGlobalRef<jobject> *gInterfaceRegistry = nullptr;
static std::unique_ptr<TaskRunner> g_task_runner = nullptr;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
  /// Init Java VM.
  InitWithJavaVM(pjvm);

  /// Init used class.
  InitClazz();

  /// Init task runner.
  g_task_runner = std::make_unique<TaskRunner>();

  return JNI_VERSION_1_6;
}

void *GetClassName(void *objectPtr) {
  if (objectPtr == nullptr) {
    return nullptr;
  }
  auto env = AttachCurrentThread();
  auto cls = FindClass("java/lang/Class", env);
  jmethodID getName = env->GetMethodID(cls.Object(), "getName", "()Ljava/lang/String;");
  auto object = static_cast<jobject>(objectPtr);
  JavaLocalRef<jclass> objCls(env->GetObjectClass(object), env);
  JavaLocalRef<jstring> jstr((jstring) env->CallObjectMethod(objCls.Object(), getName), env);
  uint16_t *clsName = JavaStringToDartString(env, jstr.Object());

  return clsName;
}

jobject _newObject(jclass cls,
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
  jobject newObj = env->NewObjectA(cls, constructor, values);

  free(constructorSignature);
  delete[]values;
  return newObj;
}

/// create target object
void *CreateTargetObject(char *targetClassName,
                         void **arguments,
                         char **argumentTypes,
                         int argumentCount,
                         uint32_t stringTypeBitmask) {
  JNIEnv *env = AttachCurrentThread();
  auto cls = FindClass(targetClassName, env);
  JavaLocalRef<jobject> newObj(_newObject(cls.Object(),
                                          arguments,
                                          argumentTypes,
                                          argumentCount,
                                          stringTypeBitmask), env);
  jobject gObj = env->NewGlobalRef(newObj.Object());
  return gObj;
}

void *InterfaceHostObjectWithName(char *name) {
  auto env = AttachCurrentThread();
  auto registryClz =
      FindClass("com/dartnative/dart_native/InterfaceRegistry", env);
  if (gInterfaceRegistry == nullptr) {
    auto instanceID =
        env->GetStaticMethodID(registryClz.Object(),
                               "getInstance",
                               "()Lcom/dartnative/dart_native/InterfaceRegistry;");
    JavaGlobalRef<jobject>
        registryObj(env->CallStaticObjectMethod(registryClz.Object(), instanceID), env);
    gInterfaceRegistry = new JavaGlobalRef<jobject>(registryObj.Object(), env);
  }

  auto getInterface =
      env->GetMethodID(registryClz.Object(),
                       "getInterface",
                       "(Ljava/lang/String;)Ljava/lang/Object;");
  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  auto interface =
      env->CallObjectMethod(gInterfaceRegistry->Object(), getInterface, interfaceName.Object());
  return interface;
}

void *InterfaceAllMetaData(char *name) {
  auto env = AttachCurrentThread();
  auto registryClz =
      FindClass("com/dartnative/dart_native/InterfaceRegistry", env);
  auto getSignatures =
      env->GetMethodID(registryClz.Object(),
                       "getMethodsSignature",
                       "(Ljava/lang/String;)Ljava/lang/String;");
  JavaLocalRef<jstring> interfaceName(env->NewStringUTF(name), env);
  JavaLocalRef<jstring> signatures((jstring) env->CallObjectMethod(gInterfaceRegistry->Object(),
                                                                   getSignatures,
                                                                   interfaceName.Object()), env);
  return JavaStringToDartString(env, signatures.Object());
}

/// dart notify run callback function
void ExecuteCallback(WorkFunction *work_ptr) {
  const WorkFunction work = *work_ptr;
  work();
  delete work_ptr;
}

/// invoke native method
void *InvokeNativeMethod(void *objPtr,
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
  auto object = static_cast<jobject>(objPtr);
  /// interface skip object check
  if (!isInterface && !ObjectInReference(object)) {
    /// maybe use cache pointer but jobject is release
    DNError(
        "InvokeNativeMethod not find class, check pointer and jobject lifecycle is same");
    return nullptr;
  }
  auto type = TaskThread(thread);
  auto invokeFunction = [=] {
    return DoInvokeNativeMethod(object, methodName, arguments, dataTypes, argumentCount, returnType,
                                stringTypeBitmask, callback, dartPort, type);
  };
  if (type == TaskThread::kFlutterUI) {
    return invokeFunction();
  }

  if (g_task_runner == nullptr) {
    DNError("InvokeNativeMethod error");
    return nullptr;
  }

  g_task_runner->ScheduleInvokeTask(type, invokeFunction);
  return nullptr;
}

/// register listener object by using java dynamic proxy
void RegisterNativeCallback(void *dartObject,
                            char *clsName,
                            char *funName,
                            void *callback,
                            Dart_Port dartPort) {
  JNIEnv *env = AttachCurrentThread();
  auto callbackManager =
      FindClass("com/dartnative/dart_native/CallbackManager", env);
  jmethodID registerCallback = env->GetStaticMethodID(callbackManager.Object(),
                                                      "registerCallback",
                                                      "(JLjava/lang/String;)Ljava/lang/Object;");

  auto dartObjectAddress = (jlong) dartObject;
  /// create interface object using java dynamic proxy
  JavaLocalRef<jstring> newClsName(env->NewStringUTF(clsName), env);
  JavaLocalRef<jobject> proxyObject(env->CallStaticObjectMethod(callbackManager.Object(),
                                                                registerCallback,
                                                                dartObjectAddress,
                                                                newClsName.Object()), env);
  jobject gProxyObj = env->NewGlobalRef(proxyObject.Object());

  /// save object into cache
  doRegisterNativeCallback(dartObject, gProxyObj, funName, callback, dartPort);
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
    const WorkFunction work =
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

  if (returnType == nullptr || strcmp(returnType, "void") == 0) {
    DNDebug("Native callback to Dart return type is void");
  } else if (strcmp(returnType, "java.lang.String") == 0) {
    callbackResult =
        DartStringToJavaString(env, (char *) arguments[argumentCount]);
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
