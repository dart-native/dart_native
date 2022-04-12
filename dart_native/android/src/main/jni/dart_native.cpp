#include <jni.h>
#include <map>
#include <string>
#include <regex>
#include <dart_api_dl.h>
#include <semaphore.h>
#include "dn_type_convert.h"
#include "dn_log.h"
#include "dn_method_call.h"
#include "dn_signature_helper.h"
#include "dn_callback.h"
#include "jni_object_ref.h"
#include "dn_thread.h"

extern "C" {

static JavaVM *gJvm = nullptr;
static JavaGlobalRef<jobject> *gClassLoader = nullptr;
static jmethodID gFindClassMethod;
static pthread_key_t detachKey = 0;

/// for invoke result compare
static JavaGlobalRef<jclass> *gStrCls = nullptr;

/// key is jobject, value is pair which contain jclass and reference count
static std::map<jobject, int> objectGlobalReference;

/// protect objectGlobalReference
std::mutex globalReferenceMtx;

static std::unique_ptr<TaskRunner> gTaskRunner;

void _addGlobalObject(jobject globalObject) {
  std::lock_guard<std::mutex> lockGuard(globalReferenceMtx);
  objectGlobalReference[globalObject] = 0;
}

bool _objectInReference(jobject globalObject) {
  std::lock_guard<std::mutex> lockGuard(globalReferenceMtx);
  auto it = objectGlobalReference.find(globalObject);
  return it != objectGlobalReference.end();
}

void _detachThreadDestructor(void *arg) {
  DNDebug("detach from current thread");
  gJvm->DetachCurrentThread();
  detachKey = 0;
}

/// each thread attach once
JNIEnv *_getEnv() {
  if (gJvm == nullptr) {
    return nullptr;
  }

  if (detachKey == 0) {
    pthread_key_create(&detachKey, _detachThreadDestructor);
  }
  JNIEnv *env;
  jint ret = gJvm->GetEnv((void **) &env, JNI_VERSION_1_6);

  switch (ret) {
    case JNI_OK:
      return env;
    case JNI_EDETACHED:
      DNDebug("attach to current thread");
      gJvm->AttachCurrentThread(&env, nullptr);
      return env;
    default:
      DNDebug("fail to get env");
      return nullptr;
  }
}

bool _clearJEnvException(JNIEnv* env) {
  jthrowable exc = env->ExceptionOccurred();

  if (exc) {
    env->ExceptionDescribe();
    env->ExceptionClear();

    return true;
  }

  return false;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
  DNDebug("JNI_OnLoad");
  /// cache the JavaVM pointer
  gJvm = pjvm;
  JNIEnv *env = _getEnv();

  /// cache classLoader
  auto plugin = env->FindClass("com/dartnative/dart_native/DartNativePlugin");
  jclass pluginClass = env->GetObjectClass(plugin);
  auto classLoaderClass = env->FindClass("java/lang/ClassLoader");
  auto getClassLoaderMethod = env->GetMethodID(pluginClass, "getClassLoader",
                                               "()Ljava/lang/ClassLoader;");
  auto classLoader = env->CallObjectMethod(plugin, getClassLoaderMethod);
  gClassLoader =
      new JavaGlobalRef<jobject>(env->NewGlobalRef(classLoader), env);
  gFindClassMethod = env->GetMethodID(classLoaderClass, "findClass",
                                      "(Ljava/lang/String;)Ljava/lang/Class;");

  /// cache string class
  jclass strCls = env->FindClass("java/lang/String");
  gStrCls =
      new JavaGlobalRef<jclass>(static_cast<jclass>(env->NewGlobalRef(strCls)),
                                env);

  env->DeleteLocalRef(classLoader);
  env->DeleteLocalRef(plugin);
  env->DeleteLocalRef(pluginClass);
  env->DeleteLocalRef(classLoaderClass);
  env->DeleteLocalRef(strCls);

  gTaskRunner = std::make_unique<TaskRunner>();
  DNDebug("JNI_OnLoad finish");
  return JNI_VERSION_1_6;
}

jclass _findClass(JNIEnv *env, const char *name) {
  jclass nativeClass = nullptr;
  nativeClass = env->FindClass(name);
  /// class loader not found class
  if (_clearJEnvException(env)) {
    jstring clsName = env->NewStringUTF(name);
    auto findedClass =
        static_cast<jclass>(env->CallObjectMethod(gClassLoader->Object(),
                                                  gFindClassMethod,
                                                  clsName));
    env->DeleteLocalRef(clsName);
    if (_clearJEnvException(env)) {
      return nullptr;
    }
    return findedClass;
  }
  return nativeClass;
}

void
_deleteArgs(jvalue *argValues, int argumentCount, uint32_t stringTypeBitmask) {
  JNIEnv *env = _getEnv();
  for (jsize index(0); index < argumentCount; ++index) {
    /// release local reference of jstring
    if ((stringTypeBitmask >> index & 0x1) == 1) {
      env->DeleteLocalRef(argValues[index].l);
    }
  }
  delete[] argValues;
}

/// fill all arguments to jvalues
/// when argument is string the stringTypeBitmask's bit is 1
void _fillArgs(void **arguments, char **argumentTypes,
               jvalue *argValues, int argumentCount,
               uint32_t stringTypeBitmask) {
  if (argumentCount == 0) {
    return;
  }

  JNIEnv *env = _getEnv();
  for (jsize index(0); index < argumentCount; ++arguments, ++index) {
    /// check basic map convert
    auto map = GetTypeConvertMap();
    auto it = map.find(*argumentTypes[index]);

    if (it == map.end()) {
      /// when argument type is string or stringTypeBitmask mark as string
      if ((stringTypeBitmask >> index & 0x1) == 1) {
        argValues[index].l = convertToJavaUtf16(env, *arguments);
      } else {
        /// convert from object cache
        /// check callback cache, if true using proxy object
        jobject object = getNativeCallbackProxyObject(*arguments);
        argValues[index].l =
            object == nullptr ? static_cast<jobject>(*arguments) : object;
      }
    } else {
      auto isTwoPointer = it->second(arguments, argValues, index);
      /// In Dart use two pointer store value.
      if (isTwoPointer) {
        arguments++;
      }
    }
  }
}

void *getClassName(void *objectPtr) {
  if (objectPtr == nullptr) {
    return nullptr;
  }
  auto env = _getEnv();
  auto cls = _findClass(env, "java/lang/Class");
  jmethodID getName = env->GetMethodID(cls, "getName", "()Ljava/lang/String;");
  auto object = static_cast<jobject>(objectPtr);
  auto objCls = env->GetObjectClass(object);
  auto jstr = (jstring) env->CallObjectMethod(objCls, getName);
  uint16_t* clsName = ConvertToDartUtf16(env, jstr);

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
  JNIEnv *env = _getEnv();
  _fillArgs(arguments,
            argumentTypes,
            argValues,
            argumentCount,
            stringTypeBitmask);

  if (_clearJEnvException(env)) {
    DNError("_newObject error, _fillArgs error!");
    return nullptr;
  }

  char *constructorSignature =
      generateSignature(argumentTypes, argumentCount, const_cast<char *>("V"));
  jmethodID constructor = env->GetMethodID(cls, "<init>", constructorSignature);

  if (!constructor) {
    _clearJEnvException(env);
    DNError("_newObject error, constructor method id is null!");
    return nullptr;
  }

  jobject newObj = env->NewObjectA(cls, constructor, argValues);
  _deleteArgs(argValues, argumentCount, stringTypeBitmask);
  free(constructorSignature);

  if (_clearJEnvException(env)) {
    DNError("_newObject error, new object error!");
    return nullptr;
  }

  return newObj;
}

/// create target object
void *createTargetObject(char *targetClassName,
                         void **arguments,
                         char **argumentTypes,
                         int argumentCount,
                         uint32_t stringTypeBitmask) {
  JNIEnv *env = _getEnv();

  if (!env) {
    DNError("createTargetObject error, JNIEnv is null");
    return nullptr;
  }

  jclass cls = _findClass(env, targetClassName);

  if (!cls) {
    DNError("createTargetObject error, findClass error");
    return nullptr;
  }

  jobject newObj = _newObject(cls,
                              arguments,
                              argumentTypes,
                              argumentCount,
                              stringTypeBitmask);

  if (!newObj) {
    return nullptr;
  }

  jobject gObj = env->NewGlobalRef(newObj);
  _addGlobalObject(gObj);

  env->DeleteLocalRef(newObj);
  env->DeleteLocalRef(cls);
  return gObj;
}

/// dart notify run callback function
void ExecuteCallback(Work *work_ptr) {
  const Work work = *work_ptr;
  work();
  delete work_ptr;
}

/// notify dart run callback function
bool NotifyDart(Dart_Port send_port, const Work *work) {
  const auto work_addr = reinterpret_cast<intptr_t>(work);

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = work_addr;

  const bool result = Dart_PostCObject_DL(send_port, &dart_object);
  if (!result) {
    DNDebug("Native callback to Dart failed! Invalid port or isolate died");
  }
  return result;
}

typedef void(*InvokeCallback)(void *result,
                              char *method,
                              char **typePointers,
                              int argumentCount);

void *_doInvokeMethod(jobject object,
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
  JNIEnv *env = _getEnv();

  if (!env) {
    DNError("_doInvokeMethod error, JNIEnv is null");
    return nullptr;
  }

  auto cls = env->GetObjectClass(object);

  auto *argValues = new jvalue[argumentCount];
  _fillArgs(arguments, typePointers, argValues, argumentCount, stringTypeBitmask);

  if (_clearJEnvException(env)) {
    DNError("_doInvokeMethod error, _fillArgs error!");
    return nullptr;
  }

  char *methodSignature =
      generateSignature(typePointers, argumentCount, returnType);
  jmethodID method = env->GetMethodID(cls, methodName, methodSignature);

  if (!method) {
    _clearJEnvException(env);
    DNError("_doInvokeMethod error, method is null!");
    return nullptr;
  }

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
        if (env->IsInstanceOf(obj, gStrCls->Object())) {
          /// mark the last pointer as string
          /// dart will check this pointer
          typePointers[argumentCount] = (char *) "java.lang.String";
          nativeInvokeResult = ConvertToDartUtf16(env, (jstring) obj);
        } else {
          typePointers[argumentCount] = (char *) "java.lang.Object";
          jobject gObj = env->NewGlobalRef(obj);
          _addGlobalObject(gObj);
          nativeInvokeResult = gObj;

          env->DeleteLocalRef(obj);
        }
      }
    }
  } else {
    *typePointers[argumentCount] = it->first;
    nativeInvokeResult = it->second(env, object, method, argValues);
  }

  if (_clearJEnvException(env)) {
    DNError("_doInvokeMethod error, invoke native method error!");
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
      const Work work =
          [callback, nativeInvokeResult, methodName, typePointers, argumentCount, isSemInitSuccess, &sem] {
            ((InvokeCallback) callback)(nativeInvokeResult,
                                        methodName,
                                        typePointers,
                                        argumentCount);
            if (isSemInitSuccess) {
              sem_post(&sem);
            }
          };
      const Work *work_ptr = new Work(work);
      /// check run result
      bool notifyResult = NotifyDart(dartPort, work_ptr);
      if (notifyResult) {
        if (isSemInitSuccess) {
          sem_wait(&sem);
          sem_destroy(&sem);
        }
      }
    }
  }

  _deleteArgs(argValues, argumentCount, stringTypeBitmask);
  free(methodName);
  free(returnType);
  free(arguments);
  free(methodSignature);
  env->DeleteLocalRef(cls);
  return nativeInvokeResult;
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
                         int thread) {
  auto object = static_cast<jobject>(objPtr);
  if (!_objectInReference(object) || objPtr == nullptr) {
    /// maybe use cache pointer but jobject is release
    DNError(
        "invokeNativeMethod not find class, check pointer and jobject lifecycle is same");
    return nullptr;
  }
  auto type = TaskThread(thread);
  auto invokeFunction = [=] {
    return _doInvokeMethod(object,
                           methodName,
                           arguments,
                           dataTypes,
                           argumentCount,
                           returnType,
                           stringTypeBitmask,
                           callback,
                           dartPort,
                           type);
  };
  if (type == TaskThread::kFlutterUI) {
    return invokeFunction();
  }

  gTaskRunner->ScheduleInvokeTask(type, invokeFunction);
  return nullptr;
}

/// register listener object by using java dynamic proxy
void registerNativeCallback(void *dartObject,
                            char *clsName,
                            char *funName,
                            void *callback,
                            Dart_Port dartPort) {
  JNIEnv *env = _getEnv();
  jclass callbackManager =
      _findClass(env, "com/dartnative/dart_native/CallbackManager");
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

/// reference counter
void _updateObjectReference(jobject globalObject, bool isRetain) {
  std::lock_guard<std::mutex> lockGuard(globalReferenceMtx);
  DNDebug("_updateObjectReference %s", isRetain ? "retain" : "release");
  auto it = objectGlobalReference.find(globalObject);
  if (it == objectGlobalReference.end()) {
    DNError("_updateObjectReference %s error not contain this object!!!",
            isRetain ? "retain" : "release");
    return;
  }

  if (isRetain) {
    /// dart object retain this dart object
    /// reference++
    it->second += 1;
    return;
  }

  /// release reference--
  it->second -= 1;

  /// no dart object retained this native object
  if (it->second <= 0) {
    JNIEnv *env = _getEnv();
    objectGlobalReference.erase(it);
    env->DeleteGlobalRef(globalObject);
  }
}

/// release native object from cache
static void RunFinalizer(void *isolate_callback_data,
                          void *peer) {
  _updateObjectReference(static_cast<jobject>(peer), false);
}

/// retain native object
void PassObjectToCUseDynamicLinking(Dart_Handle h, void *objPtr) {
  if (Dart_IsError_DL(h)) {
    DNError("Dart_IsError_DL");
    return;
  }
  _updateObjectReference(static_cast<jobject>(objPtr), true);
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
          0);
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
      _addGlobalObject(gObj);
      arguments[i] = gObj;
      env->DeleteLocalRef(argument);
    }

    env->DeleteLocalRef(argTypeString);
  }

  /// when return void, jstring which from native is null.
  char *returnType = returnTypeStr == nullptr ? nullptr
                                              : (char *) env->GetStringUTFChars(
          returnTypeStr,
          0);
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
    const Work work =
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

    const Work *work_ptr = new Work(work);
    /// check run result
    bool notifyResult = NotifyDart(port, work_ptr);
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
        convertToJavaUtf16(env, (char *) arguments[argumentCount]);
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
