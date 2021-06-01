#include <jni.h>
#include <map>
#include <string>
#include <regex>
#include <dart_api_dl.h>
#include "dn_type_convert.h"
#include "dn_log.h"
#include "dn_method_call.h"
#include "dn_signature_helper.h"
#include "dn_callback.h"

extern "C"
{

  static JavaVM *gJvm = nullptr;
  /// todo release
  static jobject gClassLoader;
  static jmethodID gFindClassMethod;
  static pthread_key_t detachKey = 0;
  /// for invoke result compare
  static jclass gStrCls;

  static std::map<jobject, jclass> objectGlobalCache;
  static std::map<jobject, int> referenceCount;

  void _detachThreadDestructor(void *arg)
  {
    DNDebug("detach from current thread");
    gJvm->DetachCurrentThread();
    detachKey = 0;
  }

  JNIEnv *_getEnv()
  {
    if (gJvm == nullptr)
    {
      return nullptr;
    }

    if (detachKey == 0)
    {
      pthread_key_create(&detachKey, _detachThreadDestructor);
    }
    JNIEnv *env;
    jint ret = gJvm->GetEnv((void **)&env, JNI_VERSION_1_6);

    switch (ret)
    {
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

  JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved)
  {
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
    gClassLoader = env->NewGlobalRef(classLoader);
    gFindClassMethod = env->GetMethodID(classLoaderClass, "findClass",
                                        "(Ljava/lang/String;)Ljava/lang/Class;");

    jclass strCls = env->FindClass("java/lang/String");
    gStrCls = static_cast<jclass>(env->NewGlobalRef(strCls));

    env->DeleteLocalRef(classLoader);
    env->DeleteLocalRef(plugin);
    env->DeleteLocalRef(pluginClass);
    env->DeleteLocalRef(classLoaderClass);
    env->DeleteLocalRef(strCls);
    DNDebug("JNI_OnLoad finish");
    return JNI_VERSION_1_6;
  }

  jclass _findClass(JNIEnv *env, const char *name)
  {
    jclass nativeClass = nullptr;
    nativeClass = env->FindClass(name);
    jthrowable exception = env->ExceptionOccurred();
    if (exception)
    {
      env->ExceptionClear();
      DNDebug("findClass exception");
      return static_cast<jclass>(env->CallObjectMethod(gClassLoader,
                                                       gFindClassMethod,
                                                       env->NewStringUTF(name)));
    }
    return nativeClass;
  }

  /// fill all arguments to jvalues
  void _fillArgs(void **arguments, char **argumentTypes, jvalue *argValues, int argumentCount, uint32_t stringTypeBitmask)
  {
    JNIEnv *env = _getEnv();
    for (jsize index(0); index < argumentCount; ++arguments, ++index, ++argumentTypes)
    {
      char *argType = *argumentTypes;
      /// check basic map convert
      auto it = basicTypeConvertMap.find(*argType);

      if (it == basicTypeConvertMap.end())
      {
        /// when argument type is string or stringTypeBitmask mark as string
        if (strcmp(argType, "Ljava/lang/String;") == 0 || (stringTypeBitmask >> index & 0x1) == 1)
        {
          convertToJavaUtf16(env, *arguments, argValues, index);
        }
        else
        {
          /// convert from object cache
          /// check callback cache, if true using proxy object
          jobject object = getNativeCallbackProxyObject(*arguments);
          argValues[index].l = object == nullptr ? static_cast<jobject>(*arguments) : object;
        }
      }
      else
      {
        it->second(arguments, argValues, index);
      }
    }
  }

  jobject _newObject(jclass cls, void **arguments, char **argumentTypes, int argumentCount, uint32_t stringTypeBitmask)
  {
    auto *argValues = new jvalue[argumentCount];
    JNIEnv *env = _getEnv();
    if (argumentCount > 0)
    {
      _fillArgs(arguments, argumentTypes, argValues, argumentCount, stringTypeBitmask);
    }

    char *constructorSignature = generateSignature(argumentTypes, argumentCount, const_cast<char *>("V"));
    jmethodID constructor = env->GetMethodID(cls, "<init>", constructorSignature);
    jobject newObj = env->NewObjectA(cls, constructor, argValues);

    delete[] argValues;
    free(constructorSignature);
    return newObj;
  }

  /// create target object
  void *createTargetObject(char *targetClassName, void **arguments, char **argumentTypes, int argumentCount, uint32_t stringTypeBitmask)
  {
    JNIEnv *env = _getEnv();
    jclass cls = _findClass(env, targetClassName);
    jobject newObj = _newObject(cls, arguments, argumentTypes, argumentCount, stringTypeBitmask);
    jobject gObj = env->NewGlobalRef(newObj);
    objectGlobalCache[gObj] = static_cast<jclass>(env->NewGlobalRef(cls));

    env->DeleteLocalRef(newObj);
    env->DeleteLocalRef(cls);
    return gObj;
  }

  /// invoke native method
  void *invokeNativeMethod(void *objPtr, char *methodName, void **arguments, char **dataTypes, int argumentCount, char *returnType, uint32_t stringTypeBitmask)
  {
    void *nativeInvokeResult = nullptr;
    JNIEnv *env = _getEnv();

    auto object = static_cast<jobject>(objPtr);
    jclass cls = objectGlobalCache[object];

    auto *argValues = new jvalue[argumentCount];
    if (argumentCount > 0)
    {
      _fillArgs(arguments, dataTypes, argValues, argumentCount, stringTypeBitmask);
    }

    char *methodSignature = generateSignature(dataTypes, argumentCount, returnType);
    DNDebug("call method %s %s", methodName, methodSignature);
    jmethodID method = env->GetMethodID(cls, methodName, methodSignature);

    auto it = methodCallerMap.find(*returnType);
    if (it == methodCallerMap.end())
    {
      if (strcmp(returnType, "Ljava/lang/String;") == 0)
      {
        nativeInvokeResult = callNativeStringMethod(env, object, method, argValues);
      }
      else
      {
        jobject obj = env->CallObjectMethodA(object, method, argValues);
        if (obj != nullptr)
        {
          if (env->IsInstanceOf(obj, gStrCls))
          {
            /// mark the last pointer as string
            /// dart will check this pointer
            *++dataTypes = (char *) "java/lang/String";
            nativeInvokeResult = convertToDartUtf16(env, (jstring)obj);
          }
          else
          {
            jclass objCls = env->GetObjectClass(obj);
            jobject gObj = env->NewGlobalRef(obj);
            objectGlobalCache[gObj] = static_cast<jclass>(env->NewGlobalRef(objCls));
            nativeInvokeResult = gObj;

            env->DeleteLocalRef(objCls);
            env->DeleteLocalRef(obj);
          }
        }
      }
    }
    else
    {
      nativeInvokeResult = it->second(env, object, method, argValues);
    }

    delete[] argValues;
    free(methodSignature);
    return nativeInvokeResult;
  }

  /// register listener object by using java dynamic proxy
  void registerNativeCallback(void *dartObject, char *clsName, char *funName, void *callback, Dart_Port dartPort)
  {
    JNIEnv *env = _getEnv();
    jclass callbackManager = _findClass(env, "com/dartnative/dart_native/CallbackManager");
    jmethodID registerCallback = env->GetStaticMethodID(callbackManager,
                                                        "registerCallback",
                                                        "(JLjava/lang/String;)Ljava/lang/Object;");

    auto dartObjectAddress = (jlong)dartObject;
    /// create interface object using java dynamic proxy
    jobject proxyObject = env->CallStaticObjectMethod(callbackManager,
                                                      registerCallback,
                                                      dartObjectAddress, env->NewStringUTF(clsName));
    jobject gProxyObj = env->NewGlobalRef(proxyObject);

    /// save object into cache
    doRegisterNativeCallback(dartObject, gProxyObj, funName, callback, dartPort);
    env->DeleteLocalRef(callbackManager);
    env->DeleteLocalRef(proxyObject);
  }

  /// init dart extensions
  intptr_t InitDartApiDL(void *data)
  {
    return Dart_InitializeApiDL(data);
  }

  /// retain native object
  void _retain(void *objPtr)
  {
    auto object = static_cast<jobject>(objPtr);
    auto it = referenceCount.find(object);
    int refCount = it == referenceCount.end() ? 1 : referenceCount[object] + 1;
    referenceCount[object] = refCount;
  }

  /// do release native object
  void _releaseTargetObject(void *objPtr)
  {
    JNIEnv *env = _getEnv();
    auto object = static_cast<jobject>(objPtr);
    env->DeleteGlobalRef(objectGlobalCache[object]);
    objectGlobalCache.erase(object);
    env->DeleteGlobalRef(object);
  }

  /// check reference count, if no reference exits then release
  void _release(void *objPtr)
  {
    auto object = static_cast<jobject>(objPtr);
    if (referenceCount.find(object) == referenceCount.end())
    {
      DNError("release error not contain object");
      return;
    }
    int count = referenceCount[object];
    if (count <= 1)
    {
      referenceCount.erase(object);
      _releaseTargetObject(objPtr);
      return;
    }
    referenceCount[object] = count - 1;
  }

  /// release native object from cache
  static void RunFinalizer(void *isolate_callback_data,
                           Dart_WeakPersistentHandle handle,
                           void *peer)
  {
    _release(peer);
  }

  /// retain native object
  void PassObjectToCUseDynamicLinking(Dart_Handle h, void *objPtr)
  {
    if (Dart_IsError_DL(h))
    {
      DNError("Dart_IsError_DL");
      return;
    }
    _retain(objPtr);
    intptr_t size = 8;
    Dart_NewWeakPersistentHandle_DL(h, objPtr, size, RunFinalizer);
  }

  /// dart notify run callback function
  void ExecuteCallback(Work *work_ptr)
  {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
  }
}
