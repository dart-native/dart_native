#include <jni.h>
#include <stdint.h>
#include <android/log.h>
#include <string.h>
#include <malloc.h>
#include <map>
#include <string>
#include <regex>

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

void fillArgsToJvalue(void **args, char **signaturesType, jvalue *argValues, int argsLength, JNIEnv *curEnv) {
    NSLog("arg length : %d", argsLength);
    for (jsize index(0); index < argsLength; ++index, ++args) {
        if (strlen(signaturesType[index]) > 1) {
            if (strcmp(signaturesType[index], "Ljava/lang/String;") == 0) {
                char * stringArg = (char *)*args;
                jclass strClass = curEnv->FindClass("java/lang/String");
                jmethodID strMethodID = curEnv->GetMethodID(strClass, "<init>","([BLjava/lang/String;)V");
                jbyteArray bytes = curEnv->NewByteArray(strlen(stringArg));
                curEnv->SetByteArrayRegion(bytes, 0, strlen(stringArg), (jbyte *) stringArg);
                jstring encoding = curEnv->NewStringUTF("utf-8");
                argValues[index].l = (jstring) curEnv->NewObject(strClass, strMethodID, bytes, encoding);
            }
        }
        else if (strcmp(signaturesType[index], "C") == 0) {
            argValues[index].c = (jchar) *(char *) args;
        }
        else if(strcmp(signaturesType[index], "I") == 0) {
            argValues[index].i = (jint) *((int *) args);
        }
        else if(strcmp(signaturesType[index], "D") == 0) {
            argValues[index].d = (jdouble) *((double *) args);
        }
        else if(strcmp(signaturesType[index], "F") == 0) {
            argValues[index].f = (jfloat) *((float *) args);
        }
        else if(strcmp(signaturesType[index], "B") == 0) {
            argValues[index].b = (jbyte) *((int8_t *) args);
        }
        else if(strcmp(signaturesType[index], "S") == 0) {
            argValues[index].s = (jshort) *((int16_t *) args);
        }
        else if(strcmp(signaturesType[index], "J") == 0) {
            argValues[index].j = (jlong) *((int64_t *) args);
        }
        else if(strcmp(signaturesType[index], "Z") == 0) {
            argValues[index].z = static_cast<jboolean>(*((int *) args));
        }
        else if(strcmp(signaturesType[index], "V") == 0) {}
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

    //todo ** length
    char **signaturesType = new char*[strlen(methodSignature)];
    int argumentsCount = 0;
    {
        std::string strSignature = methodSignature;
        std::regex regexSignature("(C|I|D|F|B|S|J|Z|V|L.*?;)");
        std::sregex_iterator itBegin(strSignature.begin(), strSignature.end(), regexSignature);
        std::sregex_iterator itEnd;
        for (std::sregex_iterator i = itBegin; i != itEnd; ++i) {
            std::smatch match = *i;
            char* type = const_cast<char *>(match.str().c_str());
            jsize const typeLength = strlen(type);
            signaturesType[argumentsCount] = new char[typeLength + 1];
            strlcpy(signaturesType[argumentsCount], type, (size_t) typeLength + 1);
            ++argumentsCount;
        }
    }

    jvalue *argValues = new jvalue[argumentsCount - 1];
    fillArgsToJvalue(args, signaturesType, argValues, argumentsCount - 1, curEnv);

    if (strlen(signaturesType[argumentsCount - 1]) > 1) {
        if (strcmp(signaturesType[argumentsCount - 1], "Ljava/lang/String;") == 0) {
            jstring nativeString = (jstring)curEnv->CallObjectMethodA(object, method, argValues);
            char *toChar = NULL;
            jclass clsstring = curEnv->FindClass("java/lang/String");
            jstring strencode = curEnv->NewStringUTF("utf-8");
            jmethodID strMethodID = curEnv->GetMethodID(clsstring, "getBytes", "(Ljava/lang/String;)[B");
            jbyteArray byteArr = (jbyteArray) curEnv->CallObjectMethod(nativeString, strMethodID, strencode);
            jsize jsLength = curEnv->GetArrayLength(byteArr);
            jbyte *rbyte = curEnv->GetByteArrayElements(byteArr, JNI_FALSE);
            if (jsLength > 0) {
                toChar = (char *) malloc(static_cast<size_t>(jsLength + 1));
                memcpy(toChar, rbyte, static_cast<size_t>(jsLength));
                toChar[jsLength] = 0;
            }
            curEnv->ReleaseByteArrayElements(byteArr, rbyte, 0);
            nativeInvokeResult = (void *) toChar;
        }
    }
    else if (strcmp(signaturesType[argumentsCount - 1], "C") == 0) {
        auto nativeChar = curEnv->CallCharMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeChar;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "I") == 0) {
        auto nativeInt = curEnv->CallIntMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeInt;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "D") == 0) {
        auto nativeDouble = curEnv->CallDoubleMethodA(object, method, argValues);
        double cDouble = (double) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(double));
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "F") == 0) {
        auto nativeDouble = curEnv->CallFloatMethodA(object, method, argValues);
        float cDouble = (float) nativeDouble;
        memcpy(&nativeInvokeResult, &cDouble, sizeof(float));
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "B") == 0) {
        auto nativeByte = curEnv->CallByteMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeByte;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "S") == 0) {
        auto nativeShort = curEnv->CallShortMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeShort;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "J") == 0) {
        auto nativeLong = curEnv->CallLongMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeLong;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "Z") == 0) {
        auto nativeBool = curEnv->CallBooleanMethodA(object, method, argValues);
        nativeInvokeResult = (void *) nativeBool;
    }
    else if(strcmp(signaturesType[argumentsCount - 1], "V") == 0) {
        curEnv->CallVoidMethodA(object, method, argValues);
    }

    free(argValues);
    free(signaturesType);
    if (bShouldDetach) {
        gJvm->DetachCurrentThread();
    }
    return nativeInvokeResult;
}

}

