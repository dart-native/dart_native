#include <jni.h>
#include <stdint.h>
#include <android/log.h>
#include <string.h>
#include <malloc.h>
#include <map>
#include <string>
#include <regex>
#include <dart_api_dl.h>
#include <semaphore.h>

extern "C" {

#define NSLog(...)  __android_log_print(ANDROID_LOG_DEBUG,"Native",__VA_ARGS__)

static JavaVM *gJvm = nullptr;
static jobject gClassLoader;
static jmethodID gFindClassMethod;
static pthread_key_t detachKey = 0;

typedef void (*NativeMethodCallback)(
    void *targetPtr,
    char *funNamePtr,
    void **args,
    char **argTypes,
    int argCount
);

static std::map<jobject, jclass> cache;
static std::map<jobject, int> referenceCount;

// todo too many cache
// for callback
static std::map<void *, jobject> callbackObjCache;
static std::map<jlong, std::map<std::string, NativeMethodCallback>> callbackManagerCache;
static std::map<jlong, void *> targetCache;
static std::map<jlong, int64_t> dartPortCache;


void detachThreadDestructor(void* arg) {
  NSLog("detach from current thread");
  gJvm->DetachCurrentThread();
  detachKey = 0;
}

JNIEnv *getEnv() {
  if (gJvm == nullptr) {
    return nullptr;
  }

  if (detachKey == 0) {
    pthread_key_create(&detachKey, detachThreadDestructor);
  }
  JNIEnv *env;
  jint ret = gJvm->GetEnv((void **) &env, JNI_VERSION_1_6);

  switch (ret) {
    case JNI_OK:
      return env;
    case JNI_EDETACHED:
      NSLog("attach to current thread");
      gJvm->AttachCurrentThread(&env, NULL);
      return env;
    default:
      NSLog("fail to get env");
      return nullptr;
  }
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
    NSLog("JNI_OnLoad");
    gJvm = pjvm;  // cache the JavaVM pointer
    //replace with one of your classes in the line below
    auto randomClass = getEnv()->FindClass("com/dartnative/dart_native/DartNativePlugin");
    jclass classClass = getEnv()->GetObjectClass(randomClass);
    auto classLoaderClass = getEnv()->FindClass("java/lang/ClassLoader");
    auto getClassLoaderMethod = getEnv()->GetMethodID(classClass, "getClassLoader",
                                                 "()Ljava/lang/ClassLoader;");
    gClassLoader = getEnv()->NewGlobalRef(getEnv()->CallObjectMethod(randomClass, getClassLoaderMethod));
    gFindClassMethod = getEnv()->GetMethodID(classLoaderClass, "findClass",
                                        "(Ljava/lang/String;)Ljava/lang/Class;");

    NSLog("JNI_OnLoad finish");
    return JNI_VERSION_1_6;
}

char *spliceChar(char *dest, char *src) {
  char *result = (char *)malloc(strlen(dest) + strlen(src));
  strcpy(result, dest);
  strcat(result, src);
  return result;
}

char *generateSignature(char **argTypes, int argCount) {
  char *signature = const_cast<char *>("(");
  if (argTypes != nullptr)
  {
    for (int i = 0; i < argCount; ++argTypes, i++) {
      char *templeSignature = spliceChar(signature, *argTypes);
      signature = templeSignature;
      free(templeSignature);
    }
  }
  return spliceChar(signature, const_cast<char *>(")"));
}

void fillArgs(void **args, char **argTypes, jvalue *argValues, int argCount) {
  for(jsize index(0); index < argCount ; ++args, ++index, ++argTypes) {
    char *argType = *argTypes;
    if (strlen(argType) > 1) {
      if (strcmp(argType, "Ljava/lang/String;") == 0) {
        argValues[index].l = getEnv()->NewStringUTF((char *)*args);
      }
      else {
        jobject object = callbackObjCache.count(*args) ? callbackObjCache[*args] : static_cast<jobject>(*args);
        argValues[index].l = object;
      }
    }
    else if (strcmp(argType, "C") == 0) {
      argValues[index].c = (jchar) *(char *) args;
    }
    else if(strcmp(argType, "I") == 0) {
      argValues[index].i = (jint) *((int *) args);
    }
    else if(strcmp(argType, "D") == 0) {
      argValues[index].d = (jdouble) *((double *) args);
    }
    else if(strcmp(argType, "F") == 0) {
      argValues[index].f = (jfloat) *((float *) args);
    }
    else if(strcmp(argType, "B") == 0) {
      argValues[index].b = (jbyte) *((int8_t *) args);
    }
    else if(strcmp(argType, "S") == 0) {
      argValues[index].s = (jshort) *((int16_t *) args);
    }
    else if(strcmp(argType, "J") == 0) {
      argValues[index].j = (jlong) *((int64_t *) args);
    }
    else if(strcmp(argType, "Z") == 0) {
      argValues[index].z = static_cast<jboolean>(*((int *) args));
    }
    else if(strcmp(argType, "V") == 0) {}
  }
}

jclass findClass(JNIEnv *env, const char *name) {
    jclass nativeClass = nullptr;
    nativeClass = env->FindClass(name);
    jthrowable exception = env->ExceptionOccurred();
    if (exception) {
      env->ExceptionClear();
      NSLog("findClass exception");
      return static_cast<jclass>(env->CallObjectMethod(gClassLoader,
                                                       gFindClassMethod,
                                                       env->NewStringUTF(name)));
    }
    return nativeClass;
}

jobject newObject(jclass cls, void **args, char **argTypes, int argCount) {
  char *signature = generateSignature(argTypes, argCount);
  jvalue *argValues = new jvalue[argCount];
  if (argCount > 0) {
    fillArgs(args, argTypes, argValues, argCount);
  }
  char *constructorSig = spliceChar(signature, const_cast<char *>("V"));
  jmethodID constructor = getEnv()->GetMethodID(cls, "<init>", constructorSig);
  jobject newObj = getEnv()->NewObjectA(cls, constructor, argValues);
  free(argValues);
  free(constructorSig);
  return newObj;
}

void *createTargetClass(char *targetClassName, void **args, char **argTypes, int argCount) {
    jclass cls = findClass(getEnv(), targetClassName);

    jobject newObj = getEnv()->NewGlobalRef(newObject(cls, args, argTypes, argCount));
    cache[newObj] = static_cast<jclass>(getEnv()->NewGlobalRef(cls));

    return newObj;
}


void releaseTargetClass(void *classPtr) {
    jobject object = static_cast<jobject>(classPtr);
    cache.erase(object);
    getEnv()->DeleteGlobalRef(object);
}

void retain(void *classPtr) {
    jobject object = static_cast<jobject>(classPtr);
    int refCount = referenceCount[object] == NULL ? 1 : referenceCount[object] + 1;
    referenceCount[object] = refCount;
}

void release(void *classPtr) {
    jobject object = static_cast<jobject>(classPtr);
    if (referenceCount[object] == NULL) {
        NSLog("not contain object");
        return;
    }
    int count = referenceCount[object];
    if (count <= 1) {
        releaseTargetClass(classPtr);
        referenceCount[object] = NULL;
        return;
    }
    referenceCount[object] = count - 1;
}

void *invokeNativeMethodNeo(void *classPtr, char *methodName, void **args, char **argTypes, int argCount, char *returnType) {
    void *nativeInvokeResult = nullptr;

    jobject object = static_cast<jobject>(classPtr);
    jclass cls = cache[object];
    char *signature = generateSignature(argTypes, argCount);
    jvalue *argValues = new jvalue[argCount];
    if (argCount > 0) {
      fillArgs(args, argTypes, argValues, argCount);
    }
    char *methodSignature = spliceChar(signature, returnType);
    jmethodID method = getEnv()->GetMethodID(cls, methodName, methodSignature);

    if (strlen(returnType) > 1) {
        if (strcmp(returnType, "Ljava/lang/String;") == 0) {
            jstring javaString = (jstring) getEnv()->CallObjectMethodA(object, method, argValues);
            jboolean isCopy = JNI_FALSE;
            nativeInvokeResult = (char *) getEnv()->GetStringUTFChars(javaString, &isCopy);
        }
        else {
            jobject obj = getEnv()->NewGlobalRef(getEnv()->CallObjectMethodA(object, method, argValues));
            jclass objCls = getEnv()->GetObjectClass(obj);
            //store class value
            cache[obj] = static_cast<jclass>(getEnv()->NewGlobalRef(objCls));
            nativeInvokeResult = obj;
        }
    }
    else if (strcmp(returnType, "C") == 0) {
        auto nativeChar = getEnv()->CallCharMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeChar;
    }
    else if(strcmp(returnType, "I") == 0) {
        auto nativeInt = getEnv()->CallIntMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeInt;
    }
    else if(strcmp(returnType, "D") == 0) {
        auto nativeDouble = getEnv()->CallDoubleMethodA(object, method, argValues);
        double cDouble = (double) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(double));
    }
    else if(strcmp(returnType, "F") == 0) {
        auto nativeDouble = getEnv()->CallFloatMethodA(object, method, argValues);
        float cDouble = (float) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(float));
    }
    else if(strcmp(returnType, "B") == 0) {
        auto nativeByte = getEnv()->CallByteMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeByte;
    }
    else if(strcmp(returnType, "S") == 0) {
        auto nativeShort = getEnv()->CallShortMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeShort;
    }
    else if(strcmp(returnType, "J") == 0) {
        auto nativeLong = getEnv()->CallLongMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeLong;
    }
    else if(strcmp(returnType, "Z") == 0) {
      auto nativeBool = getEnv()->CallBooleanMethodA(object, method, argValues);
      nativeInvokeResult = (void *) nativeBool;
    }
    else if(strcmp(returnType, "V") == 0) {
      getEnv()->CallVoidMethodA(object, method, argValues);
    }

    free(argValues);
    free(methodSignature);
    free(signature);
    return nativeInvokeResult;
}

void registerCallbackManager(jlong targetAddr, char *functionName, void *callback) {
    std::map<std::string, NativeMethodCallback> methodsMap;
    if (!callbackManagerCache.count(targetAddr)) {
        methodsMap[functionName] = (NativeMethodCallback) callback;
        callbackManagerCache[targetAddr] = methodsMap;
        return;
    }

    methodsMap = callbackManagerCache[targetAddr];
    methodsMap[functionName] = (NativeMethodCallback) callback;
    callbackManagerCache[targetAddr] = methodsMap;
}

NativeMethodCallback getCallbackMethod(jlong targetAddr, char *functionName) {
    if (!callbackManagerCache.count(targetAddr)) {
        NSLog("getCallbackMethod error not register %s", functionName);
        return NULL;
    }
    std::map<std::string, NativeMethodCallback> methodsMap = callbackManagerCache[targetAddr];
    return methodsMap[functionName];
}

void registerNativeCallback(void *target, char* targetName, char *funName, void *callback, Dart_Port dartPort) {
    jclass callbackManager = findClass(getEnv(), "com/dartnative/dart_native/CallbackManager");
    jmethodID registerCallback = getEnv()->GetStaticMethodID(callbackManager, "registerCallback", "(JLjava/lang/String;)Ljava/lang/Object;");
    jlong targetAddr = (jlong)target;
    jvalue *argValues = new jvalue[2];
    argValues[0].j = targetAddr;
    argValues[1].l = getEnv()->NewStringUTF(targetName);
    jobject callbackOJ = getEnv()->NewGlobalRef(getEnv()->CallStaticObjectMethodA(callbackManager, registerCallback, argValues));
    callbackObjCache[target] = callbackOJ;
    targetCache[targetAddr] = target;
    dartPortCache[targetAddr] = dartPort;

    registerCallbackManager(targetAddr, funName, callback);
    getEnv()->DeleteLocalRef(callbackManager);
    free(argValues);
}

// Dart extensions
intptr_t InitDartApiDL(void *data) {
    return Dart_InitializeApiDL(data);
}

static void RunFinalizer(void *isolate_callback_data,
                         Dart_WeakPersistentHandle handle,
                         void *peer) {
    NSLog("finalizer");
    release(peer);
}

void PassObjectToCUseDynamicLinking(Dart_Handle h, void *classPtr) {
    if (Dart_IsError_DL(h)) {
        return;
    }
    NSLog("retain");
    retain(classPtr);
    intptr_t size = 8;
    Dart_NewWeakPersistentHandle_DL(h, classPtr, size, RunFinalizer);
}

typedef std::function<void()> Work;

bool NotifyDart(Dart_Port send_port, const Work* work) {
    const intptr_t work_addr = reinterpret_cast<intptr_t>(work);

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = work_addr;

    const bool result = Dart_PostCObject_DL(send_port, &dart_object);
    if (!result) {
        NSLog("Native callback to Dart failed! Invalid port or isolate died");
    }
    return result;
}

void ExecuteCallback(Work* work_ptr) {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
}

JNIEXPORT jobject JNICALL Java_com_dartnative_dart_1native_CallbackInvocationHandler_hookCallback(JNIEnv *env,
                                                                                               jclass clazz,
                                                                                               jlong dartObject,
                                                                                               jstring fun_name,
                                                                                               jint arg_count,
                                                                                               jobjectArray arg_types,
                                                                                               jobjectArray args,
                                                                                               jstring return_type) {
    if (!dartPortCache.count(dartObject)) {
      NSLog("not register dart port!");
      return NULL;
    }

    char *funName = (char *) env->GetStringUTFChars(fun_name, 0);
    jsize argTypeLength = env->GetArrayLength(arg_types);
    char **argTypes = new char *[argTypeLength + 1];
    void **arguments = new void *[argTypeLength];
    for (int i = 0; i < argTypeLength; ++i) {
        jstring argTypeString = (jstring) env->GetObjectArrayElement(arg_types, i);
        jobject argument = env->GetObjectArrayElement(args, i);

        argTypes[i] = (char *) env->GetStringUTFChars(argTypeString, 0);
        env->DeleteLocalRef(argTypeString);
        //todo optimization
        if(strcmp(argTypes[i], "I") == 0) {
            jclass cls = env->FindClass("java/lang/Integer");
            if (env->IsInstanceOf(argument, cls) == JNI_TRUE) {
                jmethodID integerToInt = env->GetMethodID(cls, "intValue", "()I");
                jint result = env->CallIntMethod(argument, integerToInt);
                arguments[i] = (void *) result;
            }
            env->DeleteLocalRef(cls);
        }
        else if (strcmp(argTypes[i], "F") == 0) {
            jclass cls = env->FindClass("java/lang/Float");
            if (env->IsInstanceOf(argument, cls) == JNI_TRUE) {
                jmethodID toJfloat = env->GetMethodID(cls, "floatValue", "()F");
                jfloat result = env->CallFloatMethod(argument, toJfloat);
                float templeFloat = (float) result;
                memcpy(&arguments[i], &templeFloat, sizeof(float));
            }
            env->DeleteLocalRef(cls);
        }
        else if (strcmp(argTypes[i], "D") == 0) {
            jclass cls = env->FindClass("java/lang/Double");
            if (env->IsInstanceOf(argument, cls) == JNI_TRUE) {
                jmethodID toJfloat = env->GetMethodID(cls, "doubleValue", "()D");
                jdouble result = env->CallDoubleMethod(argument, toJfloat);
                double templeDouble = (double) result;
                memcpy(&arguments[i], &templeDouble, sizeof(double));
            }
            env->DeleteLocalRef(cls);
        }
        else if (strcmp(argTypes[i], "Ljava/lang/String;") == 0) {
            jstring argString = (jstring) argument;
            arguments[i] = argString == nullptr ? (char *) ""
                                                : (char *) env->GetStringUTFChars(argString, 0);
            env->DeleteLocalRef(argString);
        }
    }

    /// when return void, jstring which from native is null.
    char *returnType = return_type == nullptr ? nullptr
                                              : (char *) env->GetStringUTFChars(return_type, 0);

    argTypes[argTypeLength] = returnType;

    sem_t sem;
    bool isSemInitSuccess = sem_init(&sem, 0, 0) == 0;

    const Work work = [dartObject, argTypes, arguments, arg_count, funName, &sem, isSemInitSuccess]() {
        NativeMethodCallback methodCallback = getCallbackMethod(dartObject, funName);
        void *target = targetCache[dartObject];
        if (methodCallback != NULL && target != nullptr) {
            methodCallback(target, funName, arguments, argTypes, arg_count);
        }
        if (isSemInitSuccess) {
            sem_post(&sem);
        }

    };

    const Work* work_ptr = new Work(work);
    bool notifyResult = NotifyDart(dartPortCache[dartObject], work_ptr);

    jobject callbackResult = NULL;
    if (isSemInitSuccess) {
        NSLog("wait work execute");
        sem_wait(&sem);
        //todo optimization
        if (returnType == nullptr) {
          NSLog("void");
        } else if (strcmp(returnType, "Ljava/lang/String;") == 0) {
            callbackResult = env->NewStringUTF(arguments[0] == nullptr ? (char *) ""
                                                                              : (char *) arguments[0]);
        } else if (strcmp(returnType, "Z") == 0) {
          jclass booleanClass = env->FindClass("java/lang/Boolean");
          jmethodID methodID = env->GetMethodID(booleanClass, "<init>", "(Z)V");
          callbackResult = env->NewObject(booleanClass,
                                          methodID,
                                          notifyResult ? static_cast<jboolean>(*((int *) arguments))
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

}

