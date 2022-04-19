#include <semaphore.h>
#include "dn_method.h"
#include "dn_log.h"
#include "dn_thread.h"
#include "dn_lifecycle_manager.h"
#include "dn_jni_helper.h"
#include "dn_method_helper.h"
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
  JavaLocalRef<jclass> cls(env->GetObjectClass(object), env);

  auto *argValues = new jvalue[argumentCount];
  JavaLocalRef<jobject> jObjBucket[argumentCount];
  FillArgs2JValues(arguments,
                   typePointers,
                   argValues,
                   argumentCount,
                   stringTypeBitmask,
                   jObjBucket);

  char *methodSignature =
      GenerateSignature(typePointers, argumentCount, returnType);
  jmethodID method = env->GetMethodID(cls.Object(), methodName, methodSignature);
  /// Save return type, dart will use this pointer.
  typePointers[argumentCount] = returnType;

  switch (*returnType) {
    case 'C':nativeInvokeResult = (void *) env->CallCharMethodA(object, method, argValues);
      break;
    case 'I':nativeInvokeResult = (void *) env->CallIntMethodA(object, method, argValues);
      break;
    case 'D': {
      if (sizeof(void *) == 4) {
        nativeInvokeResult = (double *) malloc(sizeof(double));
      }
      auto nativeRet = env->CallDoubleMethodA(object, method, argValues);
      memcpy(&nativeInvokeResult, &nativeRet, sizeof(double));
    }
      break;
    case 'F': {
      auto fret = env->CallFloatMethodA(object, method, argValues);
      auto fvalue = (float) fret;
      memcpy(&nativeInvokeResult, &fvalue, sizeof(float));
    }
      break;
    case 'B':nativeInvokeResult = (void *) env->CallByteMethodA(object, method, argValues);
      break;
    case 'S':nativeInvokeResult = (void *) env->CallShortMethodA(object, method, argValues);
      break;
    case 'J': {
      if (sizeof(void *) == 4) {
        nativeInvokeResult = (int64_t *) malloc(sizeof(int64_t));
      }
      nativeInvokeResult = (void *) env->CallLongMethodA(object, method, argValues);
    }
      break;
    case 'Z':nativeInvokeResult = (void *) env->CallBooleanMethodA(object, method, argValues);
      break;
    case 'V':env->CallVoidMethodA(object, method, argValues);
      break;
    default:
      if (strcmp(returnType, "Ljava/lang/String;") == 0) {
        typePointers[argumentCount] = (char *) "java.lang.String";
        auto javaString = (jstring) env->CallObjectMethodA(object, method, argValues);
        nativeInvokeResult = ConvertToDartUtf16(env, javaString);
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
            nativeInvokeResult = gObj;

            env->DeleteLocalRef(obj);
          }
        }
      }
      break;
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

  free(methodName);
  free(returnType);
  free(arguments);
  free(methodSignature);
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