#include "dart_native.h"
#include "dn_thread.h"
#include "dn_log.h"
#include "dn_native_invoker.h"
#include "dn_callback.h"
#include "jni_object_ref.h"
#include "dn_jni_utils.h"
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

/// create target object
void *CreateTargetObject(char *targetClassName,
                         void **arguments,
                         char **argumentTypes,
                         int argumentCount,
                         uint32_t stringTypeBitmask) {
  JNIEnv *env = AttachCurrentThread();
  auto cls = FindClass(targetClassName, env);
  auto newObj = NewObject(cls.Object(), arguments, argumentTypes, argumentCount, stringTypeBitmask);
  jobject gObj = env->NewGlobalRef(newObj.Object());
  return gObj;
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

/// dart notify run callback function
void ExecuteCallback(WorkFunction *work_ptr) {
  const WorkFunction work = *work_ptr;
  work();
  delete work_ptr;
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
