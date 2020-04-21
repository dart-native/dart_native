#include <jni.h>
#include <stdint.h>
#include <android/log.h>
#include <string.h>
#include <malloc.h>
#include <map>
#include <string>

extern "C" {

#define NSLog(...)  __android_log_print(ANDROID_LOG_DEBUG,"Native",__VA_ARGS__)

static JavaVM *gJvm = nullptr;
static jobject gClassLoader;
static jmethodID gFindClassMethod;

static std::map<char, char *> signature_decoding = {
        {'C', "char"},
        {'I', "int"},
        {'D', "double"},
        {'F', "float"},
        {'B', "byte"},
        {'S', "short"},
        {'J', "long"},
        {'Z', "boolean"},
        {'V', "void"}
};

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

// todo 泄漏
static std::map<jobject, jclass> cache;

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

char *nativeMethodType(const char *methodName) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass cls = findClass(curEnv, "com/dartnative/dart_native/DartNative");
    char *typeResult = nullptr;

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getMethodType",
                                                     "(Ljava/lang/String;)Ljava/lang/String;");
        if (method != nullptr) {
            jstring type = (jstring) curEnv->CallStaticObjectMethod(cls, method,
                                                                    curEnv->NewStringUTF(
                                                                            methodName));
            typeResult = (char *) curEnv->GetStringUTFChars(type, 0);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return typeResult;
}

void fillArgsToJvalue(void **args, char *methodSignature, jvalue *argValues) {
    for (jsize index(1); index < strlen(methodSignature); ++index) {
        if (methodSignature[index] == ')') {
            break;
        }
        if (signature_decoding.count(methodSignature[index]) > 0) {
            switch (methodSignature[index]) {
                case 'C':
                    argValues[index - 1].c = (jchar) *(char *) args;
                    break;
                case 'I':
                    argValues[index - 1].i = (jint) *((int *) args);
                    break;
                case 'D':
                    argValues[index - 1].d = (jdouble) *((double *) args);
                    break;
                case 'F':
                    argValues[index - 1].f = (jfloat) *((float *) args);
                    break;
                case 'B':
                    argValues[index - 1].b = (jbyte) *((int8_t *) args);
                    break;
                case 'S':
                    argValues[index - 1].s = (jshort) *((int16_t *) args);
                    break;
                case 'J':
                    argValues[index - 1].j = (jlong) *((int64_t *) args);
                    break;
                case 'Z':
                    argValues[index - 1].z = static_cast<jboolean>(*((int *) args));
                    break;
                case 'V':
                    break;
                default:
                    break;
            }
            ++args;
        }
    }
}

void *invokeNativeMethod(void *classPtr, char *methodName, void **args, char *methodSignature) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;
    void *nativeInvokeResult = nullptr;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }
    jobject object = static_cast<jobject>(classPtr);
    jclass cls = cache[object];
    jmethodID method = curEnv->GetMethodID(cls, methodName, methodSignature);
    //todo spilt signature with () arg length
    jvalue *argValues = new jvalue[1];
    fillArgsToJvalue(args, methodSignature, argValues);
    switch (methodSignature[strlen(methodSignature) - 1]) {
        case 'C': {
            auto nativeChar = curEnv->CallCharMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeChar;
        }
            break;
        case 'I': {
            auto nativeInt = curEnv->CallIntMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeInt;
        }
            break;
        case 'D': {
            auto nativeDouble = curEnv->CallDoubleMethodA(object, method, argValues);
            double cDouble = (double) nativeDouble;
            memcpy(&nativeInvokeResult, &cDouble, sizeof(double));
        }
            break;
        case 'F': {
            auto nativeDouble = curEnv->CallFloatMethodA(object, method, argValues);
            float cDouble = (float) nativeDouble;
            memcpy(&nativeInvokeResult, &cDouble, sizeof(float));
        }
            break;
        case 'B': {
            auto nativeByte = curEnv->CallByteMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeByte;
        }
            break;
        case 'S': {
            auto nativeShort = curEnv->CallShortMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeShort;
        }
            break;
        case 'J': {
            auto nativeLong = curEnv->CallLongMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeLong;
        }
            break;
        case 'Z': {
            auto nativeBool = curEnv->CallBooleanMethodA(object, method, argValues);
            nativeInvokeResult = (void *) nativeBool;
        }
            break;
        case 'V':
            break;
        default:
            break;
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }
    return nativeInvokeResult;
}

}

