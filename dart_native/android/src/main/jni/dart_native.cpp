#include <jni.h>
#include <stdint.h>
#include <android/log.h>
#include <string.h>
#include <malloc.h>
#include <map>
#include <string>
#include <regex>
#include <dart_api_dl.h>

class MethodNativeCallback
{
    public:
        jclass clz;
        jobject oj;
};

extern "C" {

#define NSLog(...)  __android_log_print(ANDROID_LOG_DEBUG,"Native",__VA_ARGS__)

static JavaVM *gJvm = nullptr;
static jobject gClassLoader;
static jmethodID gFindClassMethod;

JNIEnv *getEnv() {
    JNIEnv *env;
    int status = gJvm->GetEnv((void **) &env, JNI_VERSION_1_6);
    if (status < 0) {
        status = gJvm->AttachCurrentThread(&env, NULL);
        if (status < 0) {
            return nullptr;
        }
    }
    return env;
}

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *pjvm, void *reserved) {
    NSLog("JNI_OnLoad");
    gJvm = pjvm;  // cache the JavaVM pointer
    auto env = getEnv();
    //replace with one of your classes in the line below
    auto randomClass = env->FindClass("com/dartnative/dart_native/DartNative");
    jclass classClass = env->GetObjectClass(randomClass);
    auto classLoaderClass = env->FindClass("java/lang/ClassLoader");
    auto getClassLoaderMethod = env->GetMethodID(classClass, "getClassLoader",
                                                 "()Ljava/lang/ClassLoader;");
    gClassLoader = env->NewGlobalRef(env->CallObjectMethod(randomClass, getClassLoaderMethod));
    gFindClassMethod = env->GetMethodID(classLoaderClass, "findClass",
                                        "(Ljava/lang/String;)Ljava/lang/Class;");

    NSLog("JNI_OnLoad finish");
    return JNI_VERSION_1_6;
}

jclass findClass(JNIEnv *env, const char *name) {
    if (gClassLoader == NULL || gFindClassMethod == NULL) {
        NSLog("findClass error !");
    }
    return static_cast<jclass>(env->CallObjectMethod(gClassLoader, gFindClassMethod,
                                                     env->NewStringUTF(name)));
}

static std::map<jobject, jclass> cache;
static std::map<jobject, int> referenceCount;
static std::map<void *, jobject> callbackCache;

void *createTargetClass(char *targetClassName) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass cls = findClass(curEnv, targetClassName);
    jmethodID constructor = curEnv->GetMethodID(cls, "<init>", "()V");
    jobject newObject = curEnv->NewGlobalRef(curEnv->NewObject(cls, constructor));
    cache[newObject] = static_cast<jclass>(curEnv->NewGlobalRef(cls));


    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return newObject;
}


void releaseTargetClass(void *classPtr) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jobject object = static_cast<jobject>(classPtr);
    curEnv->DeleteGlobalRef(object);
    cache[object] = NULL;

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }
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

char *spliceChar(char *dest, char *src) {
    char *result = (char *)malloc(strlen(dest) + strlen(src));
    strcpy(result, dest);
    strcat(result, src);
    return result;
}

char *generateSignature(char **argTypes) {
    char *signature = const_cast<char *>("(");
    int argCount = 0;
    for(; *argTypes ; ++argTypes, ++argCount) {
        signature = spliceChar(signature, *argTypes);
    }
    return spliceChar(signature, const_cast<char *>(")"));
}

void fillArgs(void **args, char **argTypes, jvalue *argValues, JNIEnv *curEnv) {
    for(jsize index(0); *argTypes ; ++args, ++index, ++argTypes) {
        char *argType = *argTypes;
        if (strlen(argType) > 1) {
            if (strcmp(argType, "Ljava/lang/String;") == 0) {
                argValues[index].l = curEnv->NewStringUTF((char *)*args);
            }
            else {
                jobject object;
                if (callbackCache.count(*args)) {
                    NSLog("HUIZZ cache has register");
                    object = callbackCache[*args];
                } else {
                    object = static_cast<jobject>(*args);
                }
                if (object == NULL) {
                    NSLog("HUIZZ oj is null");
                }
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


void *invokeNativeMethodNeo(void *classPtr, char *methodName, void **args, char **argTypes, char *returnType) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;
    void *nativeInvokeResult = nullptr;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
    }
    jobject object = static_cast<jobject>(classPtr);
    jclass cls = cache[object];

    char *signature = generateSignature(argTypes);
    jvalue *argValues = new jvalue[strlen(signature) - 2];
    fillArgs(args, argTypes, argValues, curEnv);
    jmethodID method = curEnv->GetMethodID(cls, methodName, spliceChar(signature, returnType));

    if (strlen(returnType) > 1) {
        if (strcmp(returnType, "Ljava/lang/String;") == 0) {
            jstring javaString = (jstring)curEnv->CallObjectMethodA(object, method, argValues);
            nativeInvokeResult = (char *) curEnv->GetStringUTFChars(javaString, 0);
            curEnv->DeleteLocalRef(javaString);
        }
        else {
            jobject obj = curEnv->NewGlobalRef(curEnv->CallObjectMethodA(object, method, argValues));
            //store class value
            char* clsName= new char[strlen(returnType)];
            strlcpy(clsName, returnType + 1, strlen(returnType) - 1);
            cache[obj] = static_cast<jclass>(curEnv->NewGlobalRef(findClass(curEnv, clsName)));
            free(clsName);
            nativeInvokeResult = obj;
        }
    }
    else if (strcmp(returnType, "C") == 0) {
        auto nativeChar = curEnv->CallCharMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeChar;
    }
    else if(strcmp(returnType, "I") == 0) {
        auto nativeInt = curEnv->CallIntMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeInt;
    }
    else if(strcmp(returnType, "D") == 0) {
        auto nativeDouble = curEnv->CallDoubleMethodA(object, method, argValues);
        double cDouble = (double) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(double));
    }
    else if(strcmp(returnType, "F") == 0) {
        auto nativeDouble = curEnv->CallFloatMethodA(object, method, argValues);
        float cDouble = (float) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(float));
    }
    else if(strcmp(returnType, "B") == 0) {
        auto nativeByte = curEnv->CallByteMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeByte;
    }
    else if(strcmp(returnType, "S") == 0) {
        auto nativeShort = curEnv->CallShortMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeShort;
    }
    else if(strcmp(returnType, "J") == 0) {
        auto nativeLong = curEnv->CallLongMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeLong;
    }
    else if(strcmp(returnType, "Z") == 0) {
        auto nativeBool = curEnv->CallBooleanMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeBool;
    }
    else if(strcmp(returnType, "V") == 0) {
        curEnv->CallVoidMethodA(object, method, argValues);
    }

    free(argValues);
    free(signature);
    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }
    return nativeInvokeResult;
}

void registerNativeCallback(void *target, char* targetName, char *funName, void *callback) {
    NSLog("funname %s", funName);
    JNIEnv *curEnv;
    bool bShouldDetach = false;
    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass callbackManager = findClass(curEnv, "com/dartnative/dart_native/CallbackManager");
    jmethodID registerCallback = curEnv->GetStaticMethodID(callbackManager, "registerCallback", "(Ljava/lang/String;)Ljava/lang/Object;");
    jvalue *argValues = new jvalue[1];
    argValues[0].l = curEnv->NewStringUTF(targetName);
    jobject callbackOJ = curEnv->CallStaticObjectMethodA(callbackManager, registerCallback, argValues);
    callbackCache[target] = curEnv->NewGlobalRef(callbackOJ);
    curEnv->DeleteLocalRef(callbackManager);

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }
}

// Dart extensions
intptr_t InitDartApiDL(void *data, Dart_Port port) {
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

void NotifyDart(Dart_Port send_port, const Work* work) {
    const intptr_t work_addr = reinterpret_cast<intptr_t>(work);

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = work_addr;

    const bool result = Dart_PostCObject_DL(send_port, &dart_object);
    if (!result) {
        NSLog("Native callback to Dart failed! Invalid port or isolate died");
    }
}

void ExecuteCallback(Work* work_ptr) {
    const Work work = *work_ptr;
    work();
    delete work_ptr;
}

JNIEXPORT void JNICALL Java_com_dartnative_dart_1native_CallbackManager_hookCallback(JNIEnv *env,
                                                                                     jclass clazz,
                                                                                     jobject oj) {
    NSLog("call back from native");
}

}

