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

char *invokeNativeMethod(char* methodName, void **args) {
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

            char *methodReturnType = nativeMethodType(methodName);
            char *signature = generateSignature(methodReturnType, arrArgTypes, length);
            NSLog("%s return %s signature %s", methodName, methodReturnType, signature);


            void **arrArgs = new void*[length];
            for(jsize index(0); *args ; ++args, ++index) {

                if (strcmp(arrArgTypes[index], "boolean") == 0
                    || strcmp(arrArgTypes[index], "int") == 0) {
                    NSLog("bool or int param %d", *((int *)args));
                    arrArgs[index] = (int *) args;
                }

                if (strcmp(arrArgTypes[index], "char") == 0) {
                    NSLog("char param : %s", (char *)args);
                    arrArgs[index] = (char *)args;
                }
            }

            if (strcmp(methodReturnType, "char") == 0) {
                jmethodID nativeMethod = curEnv->GetStaticMethodID(cls, methodName, signature);
                if (nativeMethod != nullptr) {
                    char *charArg = (char *)arrArgs[0];
                    jchar nativeChar = curEnv->CallStaticCharMethod(cls, nativeMethod, (jchar)*charArg);
                    char cChar = (char) nativeChar;
                    nativeRunResult = & cChar;
                }
            }

            if (strcmp(methodReturnType, "int") == 0) {
                jmethodID nativeMethod = curEnv->GetStaticMethodID(cls, methodName, signature);
                if (nativeMethod != nullptr) {
                    jint nativeInt = curEnv->CallStaticIntMethod(cls, nativeMethod, (jint)*((int *)arrArgs[0]));
                    const char* to_char = std::to_string(nativeInt).c_str();
                    char* cInt = new char[strlen(to_char)];
                    strlcpy(cInt, to_char, strlen(to_char));
                    nativeRunResult = cInt;
                }
            }

            if (strcmp(methodReturnType, "boolean") == 0) {
                jmethodID nativeMethod = curEnv->GetStaticMethodID(cls, methodName, signature);
                if (nativeMethod != nullptr) {
                    jint nativeBool = curEnv->CallStaticBooleanMethod(cls, nativeMethod, *((int *)arrArgs) ? JNI_TRUE : JNI_FALSE);
                    char cBool = static_cast<char>(nativeBool + '0');
                    nativeRunResult = &cBool;
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

