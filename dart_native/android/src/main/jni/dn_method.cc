#include <semaphore.h>
#include "dn_method.h"
#include "dn_log.h"
#include "dn_thread.h"
#include "dn_lifecycle_manager.h"
#include "dn_jni_helper.h"
#include "dn_signature_helper.h"
#include "dn_method_call.h"
#include "dn_type_convert.h"
#include "dn_dart_api.h"

namespace dartnative {

static std::unique_ptr<TaskRunner> g_task_runner = nullptr;

DNMethod::DNMethod(void *target,
                   char *methodName,
                   char **argsType,
                   char *returnType,
                   int argCount,
                   Dart_Port dart_port,
                   void *callback)
    : target_(target),
      methodName_(methodName),
      argsType_(argsType),
      returnType_(returnType),
      argCount_(argCount),
      dart_port_(dart_port),
      callback_(callback) {}


void *doInvokeNativeMethod(jobject object,
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
  auto cls = env->GetObjectClass(object);

  auto *argValues = new jvalue[argumentCount];
  FillArgs2JValues(arguments, typePointers, argValues, argumentCount, stringTypeBitmask);

  char *methodSignature =
      generateSignature(typePointers, argumentCount, returnType);
  jmethodID method = env->GetMethodID(cls, methodName, methodSignature);

  auto map = GetMethodCallerMap();
  auto it = map.find(*returnType);
  if (it == map.end()) {
    if (strcmp(returnType, "Ljava/lang/String;") == 0) {
      typePointers[argumentCount] = (char *) "java.lang.String";
      nativeInvokeResult =
          callNativeStringMethod(env, object, method, argValues);
    } else {
      jobject obj = env->CallObjectMethodA(object, method, argValues);
      if (obj != nullptr) {
        if (env->IsInstanceOf(obj, GetStringClazz())) {
          /// mark the last pointer as string
          /// dart will check this pointer
          typePointers[argumentCount] = (char *) "java.lang.String";
          nativeInvokeResult = ConvertToDartUtf16(env, (jstring) obj);
        } else {
          typePointers[argumentCount] = (char *) "java.lang.Object";
          jobject gObj = env->NewGlobalRef(obj);
//          _addGlobalObject(gObj);
          nativeInvokeResult = gObj;

          env->DeleteLocalRef(obj);
        }
      }
    }
  } else {
    *typePointers[argumentCount] = it->first;
    nativeInvokeResult = it->second(env, object, method, argValues);
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
      const DartWorkFunction work =
          [callback, nativeInvokeResult, methodName, typePointers, argumentCount, isSemInitSuccess, &sem] {
            ((InvokeCallback) callback)(nativeInvokeResult,
                                        methodName,
                                        typePointers,
                                        argumentCount);
            if (isSemInitSuccess) {
              sem_post(&sem);
            }
          };
      const DartWorkFunction *work_ptr = new DartWorkFunction(work);
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

//  _deleteArgs(argValues, argumentCount, stringTypeBitmask);
  free(methodName);
  free(returnType);
  free(arguments);
  free(methodSignature);
  env->DeleteLocalRef(cls);
  return nativeInvokeResult;
}

void *DNMethod::InvokeNativeMethod(void **arguments,
                                   uint32_t stringTypeBitmask,
                                   int thread,
                                   bool isInterface) {
  auto object = static_cast<jobject>(target_);
  /// interface skip object check
  if (!isInterface && !ObjectInReference(object)) {
    /// maybe use cache pointer but jobject is release
    DNError(
        "invokeNativeMethod not find class, check pointer and jobject lifecycle is same");
    return nullptr;
  }
  auto type = TaskThread(thread);
  auto invokeFunction = [=] {
    return doInvokeNativeMethod(object,
                                methodName_,
                                arguments,
                                argsType_,
                                argCount_,
                                returnType_,
                                stringTypeBitmask,
                                callback_,
                                dart_port_,
                                type);
  };
  if (type == TaskThread::kFlutterUI) {
    return invokeFunction();
  }

  if (g_task_runner == nullptr) {
    g_task_runner = std::make_unique<TaskRunner>();
  }

  g_task_runner->ScheduleInvokeTask(type, invokeFunction);
  return nullptr;

}

void DNMethod::InvokeDartMethod() {

}

}