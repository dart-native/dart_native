#include "dart_native.h"
#include "dn_thread.h"
#include "dn_log.h"
#include "dn_native_invoker.h"
#include "dn_callback.h"
#include "jni_object_ref.h"
#include "dn_jni_utils.h"
#include "dn_lifecycle_manager.h"
#include "dn_interface.h"

using namespace dartnative;

static std::unique_ptr<TaskRunner> g_task_runner = nullptr;

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
  /// Init Java VM.
  InitWithJavaVM(pjvm);

  auto env = AttachCurrentThread();
  if (env == nullptr) {
    DNError("No JNIEnv provided!");
    return JNI_VERSION_1_6;
  }

  /// Init used class.
  InitClazz(env);

  /// Init task runner.
  g_task_runner = std::make_unique<TaskRunner>();

  /// Init interface.
  InitInterface(env);

  return JNI_VERSION_1_6;
}

intptr_t InitDartApiDL(void *data) {
  return Dart_InitializeApiDL(data);
}

/// release native object from cache
static void RunFinalizer(void *isolate_callback_data,
                         void *peer) {
  ReleaseJObject(static_cast<jobject>(peer));
}

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
  if (env == nullptr) {
    return nullptr;
  }

  return InterfaceWithName(name, env);
}

void *InterfaceAllMetaData(char *name) {
  auto env = AttachCurrentThread();
  if (env == nullptr) {
    return nullptr;
  }

  return InterfaceMetaData(name, env);
}

void InterfaceRegisterDartInterface(char *interface, char *method,
                                    void *callback, Dart_Port dartPort) {
  RegisterDartInterface(interface, method, callback, dartPort);
}
