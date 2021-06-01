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

  void detachThreadDestructor(void *arg)
  {
    DNDebug("detach from current thread");
    gJvm->DetachCurrentThread();
    detachKey = 0;
  }

  JNIEnv *getEnv()
  {
    if (gJvm == nullptr)
    {
      return nullptr;
    }

    if (detachKey == 0)
    {
      pthread_key_create(&detachKey, detachThreadDestructor);
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
    JNIEnv *env = getEnv();

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

  void fillArgs(void **args, char **argTypes, jvalue *argValues, int argCount, uint32_t stringTypeBitmask)
  {
    for (jsize index(0); index < argCount; ++args, ++index, ++argTypes)
    {
      char *argType = *argTypes;
      /// check basic map convert
      auto it = basicTypeConvertMap.find(*argType);

      if (it == basicTypeConvertMap.end())
      {
        /// when argument type is string or stringTypeBitmask mark as string
        if (strcmp(argType, "Ljava/lang/String;") == 0 || (stringTypeBitmask >> index & 0x1) == 1)
        {
          convertToJavaUtf16(getEnv(), *args, argValues, index);
        }
        else
        {
          /// convert from object cache
          /// check callback cache, if true using proxy object
          jobject object = getNativeCallbackProxyObject(*args);
          argValues[index].l = object == nullptr ? static_cast<jobject>(*args) : object;
        }
      }
      else
      {
        it->second(args, argValues, index);
      }
    }
  }

  jclass findClass(JNIEnv *env, const char *name)
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

  jobject newObject(jclass cls, void **args, char **argTypes, int argCount, uint32_t stringTypeBitmask)
  {
    auto *argValues = new jvalue[argCount];
    if (argCount > 0)
    {
      fillArgs(args, argTypes, argValues, argCount, stringTypeBitmask);
    }

    char *constructorSignature = generateSignature(argTypes, argCount, const_cast<char *>("V"));
    jmethodID constructor = getEnv()->GetMethodID(cls, "<init>", constructorSignature);
    jobject newObj = getEnv()->NewObjectA(cls, constructor, argValues);

    delete[] argValues;
    free(constructorSignature);
    return newObj;
  }

  void *createTargetClass(char *targetClassName, void **args, char **argTypes, int argCount, uint32_t stringTypeBitmask)
  {
    JNIEnv *env = getEnv();
    jclass cls = findClass(env, targetClassName);
    jobject newObj = newObject(cls, args, argTypes, argCount, stringTypeBitmask);
    jobject gObj = env->NewGlobalRef(newObj);
    objectGlobalCache[gObj] = static_cast<jclass>(env->NewGlobalRef(cls));

    env->DeleteLocalRef(newObj);
    env->DeleteLocalRef(cls);
    return gObj;
  }

  void releaseTargetClass(void *objPtr)
  {
    auto object = static_cast<jobject>(objPtr);
    getEnv()->DeleteGlobalRef(objectGlobalCache[object]);
    objectGlobalCache.erase(object);
    getEnv()->DeleteGlobalRef(object);
  }

  void retain(void *objPtr)
  {
    auto object = static_cast<jobject>(objPtr);
    auto it = referenceCount.find(object);
    int refCount = it == referenceCount.end() ? 1 : referenceCount[object] + 1;
    referenceCount[object] = refCount;
  }

  void release(void *objPtr)
  {
    auto object = static_cast<jobject>(objPtr);
    if (referenceCount.find(object) == referenceCount.end())
    {
      DNDebug("not contain object");
      return;
    }
    int count = referenceCount[object];
    if (count <= 1)
    {
      referenceCount.erase(object);
      releaseTargetClass(objPtr);
      return;
    }
    referenceCount[object] = count - 1;
  }

  void *invokeNativeMethod(void *objPtr, char *methodName, void **args, char **argTypes, int argCount, char *returnType, uint32_t stringTypeBitmask)
  {
    void *nativeInvokeResult = nullptr;
    JNIEnv *env = getEnv();

    auto object = static_cast<jobject>(objPtr);
    jclass cls = objectGlobalCache[object];

    auto *argValues = new jvalue[argCount];
    if (argCount > 0)
    {
      fillArgs(args, argTypes, argValues, argCount, stringTypeBitmask);
    }

    char *methodSignature = generateSignature(argTypes, argCount, returnType);
    DNDebug("call method %s %s", methodName, methodSignature);
    jmethodID method = getEnv()->GetMethodID(cls, methodName, methodSignature);

    auto it = methodCallerMap.find(*returnType);
    if (it == methodCallerMap.end())
    {
      if (strcmp(returnType, "Ljava/lang/String;") == 0)
      {
        nativeInvokeResult = callNativeStringMethod(getEnv(), object, method, argValues);
      }
      else
      {
        jobject obj = getEnv()->CallObjectMethodA(object, method, argValues);
        if (obj != nullptr)
        {
          if (getEnv()->IsInstanceOf(obj, gStrCls))
          {
            *++argTypes = (char *)"1";
            nativeInvokeResult = convertToDartUtf16(getEnv(), (jstring)obj);
          }
          else
          {
            jclass objCls = getEnv()->GetObjectClass(obj);
            jobject gObj = getEnv()->NewGlobalRef(obj);
            //store class value
            objectGlobalCache[gObj] = static_cast<jclass>(getEnv()->NewGlobalRef(objCls));
            nativeInvokeResult = gObj;

            getEnv()->DeleteLocalRef(objCls);
            getEnv()->DeleteLocalRef(obj);
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

  void registerNativeCallback(void *dartObject, char *clsName, char *funName, void *callback, Dart_Port dartPort)
  {
    JNIEnv *env = getEnv();
    jclass callbackManager = findClass(env, "com/dartnative/dart_native/CallbackManager");
    jmethodID registerCallback = env->GetStaticMethodID(callbackManager,
                                                  "registerCallback",
                                                    "(JLjava/lang/String;)Ljava/lang/Object;");

    auto dartObjectAddress = (jlong) dartObject;
    jobject proxyObject = env->CallStaticObjectMethod(callbackManager,
                                                      registerCallback,
                                                      dartObjectAddress, env->NewStringUTF(clsName));
    jobject gProxyObj = env->NewGlobalRef(proxyObject);

    doRegisterNativeCallback(dartObject, gProxyObj, funName, callback, dartPort);
    env->DeleteLocalRef(callbackManager);
    env->DeleteLocalRef(proxyObject);
  }

  // Dart extensions
  intptr_t InitDartApiDL(void *data)
  {
    return Dart_InitializeApiDL(data);
  }

  static void RunFinalizer(void *isolate_callback_data,
                           Dart_WeakPersistentHandle handle,
                           void *peer)
  {
    //    DNDebug("finalizer");
    release(peer);
  }

  void PassObjectToCUseDynamicLinking(Dart_Handle h, void *classPtr)
  {
    if (Dart_IsError_DL(h))
    {
      return;
    }
    //    DNDebug("retain");
    retain(classPtr);
    intptr_t size = 8;
    Dart_NewWeakPersistentHandle_DL(h, classPtr, size, RunFinalizer);
  }

  void ExecuteCallback(Work *work_ptr)
  {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
  }
}
