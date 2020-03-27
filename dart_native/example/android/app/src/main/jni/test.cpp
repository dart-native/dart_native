//
// Created by siriushe on 2019/11/7.
//

#include <jni.h>
#include <stdint.h>
#include <android/log.h>


extern "C" {

#define NSLog(...)  __android_log_print(ANDROID_LOG_DEBUG,"Sirius_Native",__VA_ARGS__)

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
    auto randomClass = env->FindClass("com/dartnative/dart_native_example/MainActivity");
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

jclass findClass(JNIEnv *env, const char* name) {
    if (gClassLoader == NULL || gFindClassMethod == NULL) {
        NSLog("findClass error !");
    }
    return static_cast<jclass>(env->CallObjectMethod(gClassLoader, gFindClassMethod, env->NewStringUTF(name)));
}

int32_t getPlatformInt() {
    //NSLog("getPlatform");

    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    int32_t ret = 10088;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getNumber", "()I");
        if (method != nullptr) {
            ret = curEnv->CallStaticIntMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}

double getPlatformDouble() {

    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    double ret = 10088.23;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getDouble", "()D");
        if (method != nullptr) {
            ret = curEnv->CallStaticDoubleMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}

jbyte getPlatformByte() {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jbyte ret = 1;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getByte", "()B");
        if (method != nullptr) {
            ret = curEnv->CallStaticByteMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}


jshort getPlatformShort() {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jshort ret = 1;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getShort", "()S");
        if (method != nullptr) {
            ret = curEnv->CallStaticShortMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}

jlong getPlatformLong() {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jlong ret = 1;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getLong", "()J");
        if (method != nullptr) {
            ret = curEnv->CallStaticLongMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}


float getPlatformFloat() {

    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    float ret = 10088.2;

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getFloat", "()F");
        if (method != nullptr) {
            ret = curEnv->CallStaticFloatMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}

char getPlatformChar() {

    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    char ret = 'b';

    //NSLog("findClass start");

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    //NSLog("findClass success!");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getChar", "()C");
        if (method != nullptr) {
            ret = curEnv->CallStaticCharMethod(cls, method);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return ret;
}

}

