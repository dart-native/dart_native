//
// Created by siriushe on 2019/11/7.
//

#include <jni.h>
#include <stdint.h>
#include <android/log.h>
#include <string.h>
#include <malloc.h>
#include <map>
#include <string>

extern "C" {

#define NSLog(...)  __android_log_print(ANDROID_LOG_DEBUG,"Sirius_Native",__VA_ARGS__)

static JavaVM *gJvm = nullptr;
static jobject gClassLoader;
static jmethodID gFindClassMethod;

static std::map<std::string, char *> basic_type_to_signature = {
        {"char", "C"},
        {"int", "I"},
        {"double", "D"},
        {"float", "F"},
        {"byte", "B"},
        {"short", "S"},
        {"long", "J"},
        {"boolean", "Z"}
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

char *nativeMethodType(const char *methodName) {

    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");
    char *typeResult = nullptr;

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getMethodType", "(Ljava/lang/String;)Ljava/lang/String;");
        if (method != nullptr) {
            jstring type = (jstring) curEnv->CallStaticObjectMethod(cls, method, curEnv->NewStringUTF(methodName));
            typeResult = (char *)curEnv->GetStringUTFChars(type, 0);
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return typeResult;
}

jmethodID  *nativeMethod() {
    JNIEnv *curEnv;
    bool bShouldDetach = false;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");
    jmethodID *methodResult = nullptr;

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getMethod", "(Ljava/lang/String;)Ljava/lang/reflect/Method;");
        if (method != nullptr) {
            methodResult = (jmethodID *)curEnv->CallStaticObjectMethod(cls, method, curEnv->NewStringUTF("getChar"));
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return methodResult;
}
char *spliceChar(char *dest, char *src) {
    char *result = (char *)malloc(strlen(dest) + strlen(src));
    strcpy(result, dest);
    strcat(result, src);
    return result;
}


char *generateSignature(char *methodReturnType, char **argTypes, int length) {
    char *signature = const_cast<char *>("(");
    for (size_t i = 0; i < length; i++) {
        if (basic_type_to_signature.count(argTypes[i]) > 0) {
            signature = spliceChar(signature, basic_type_to_signature.at(argTypes[i]));
        }
    }
    signature = spliceChar(signature, const_cast<char *>(")"));
    if (basic_type_to_signature.count(methodReturnType) > 0) {
        signature = spliceChar(signature, basic_type_to_signature.at(methodReturnType));
    }
    return signature;
}

void *invokeNativeMethod(char* methodName, void **args) {
    JNIEnv *curEnv;
    bool bShouldDetach = false;
    char *nativeRunResult = nullptr;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        bShouldDetach = true;
        NSLog("AttachCurrentThread : %d", error);
    }

    jclass cls = findClass(curEnv, "com/dartnative/dart_native_example/MainActivity");

    if (cls != nullptr) {
        jmethodID method = curEnv->GetStaticMethodID(cls, "getMethodParams", "(Ljava/lang/String;)[Ljava/lang/String;");
        if (method != nullptr) {
            jarray methodResult = (jarray)curEnv->CallStaticObjectMethod(cls, method, curEnv->NewStringUTF(methodName));
            // assumption: the result of getData() is never null
            jsize const length = curEnv->GetArrayLength(methodResult);
            // assumption: the String[] is always of length > 0
            char** arrArgTypes = new char*[length];

            for(jsize index(0); index < length; ++index) {
                jstring element = (jstring) curEnv->GetObjectArrayElement((jobjectArray)methodResult, index);

                // assumption: there are no null strings in the array
                char const* nativeString = curEnv->GetStringUTFChars(element, 0);
                jsize const nativeLength = strlen(nativeString);

                arrArgTypes[index] = new char[nativeLength + 1];
                strlcpy(arrArgTypes[index], nativeString, (size_t) nativeLength + 1);

                curEnv->ReleaseStringUTFChars(element, nativeString);
                curEnv->DeleteLocalRef(element);
            }

            char **arrArgs = new char*[length];
            jint* intValue;
            for(jsize index(0); *args ; ++args, ++index) {
//                if (strcmp(arrArgTypes[index], "int") == 0) {
////                    intValue = (jint*)args;
//                    int t = atoi((char *)args);
//                    NSLog("int param : %s %d", (char *)args, t);
//                }

                NSLog("arg param : %s", (char *)args);
                jsize const paramLength = strlen((char *)args);
                arrArgs[index] = new char[paramLength + 1];
                strlcpy(arrArgs[index], (char *)args, (size_t) paramLength + 1);
            }
            char *methodReturnType = nativeMethodType(methodName);
            char *signature = generateSignature(methodReturnType, arrArgTypes, length);

            if (strcmp(methodReturnType, "char") == 0) {
                jmethodID nativeMethod = curEnv->GetStaticMethodID(cls, methodName, signature);
                if (nativeMethod != nullptr) {
                    //todo char to jchar; jchar to char
                    curEnv->CallStaticCharMethod(cls, nativeMethod, L'A');
                    nativeRunResult = (char *)"B";
                }
            }

            if (strcmp(methodReturnType, "int") == 0) {
                jmethodID nativeMethod = curEnv->GetStaticMethodID(cls, methodName, signature);
                if (nativeMethod != nullptr) {
                    jint jt = curEnv->CallStaticIntMethod(cls, nativeMethod, 10);
                    int32_t intVa = (int32_t) jt;
                    NSLog("CallStaticIntMethod : %d", intVa);
                }
            }
        }
    }

    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }

    return nativeRunResult;

}

}

