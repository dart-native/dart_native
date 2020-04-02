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
    static jobject gTargetClass;

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

    jclass findClass(JNIEnv *env, const char* name) {
        if (gClassLoader == NULL || gFindClassMethod == NULL) {
            NSLog("findClass error !");
        }
        return static_cast<jclass>(env->CallObjectMethod(gClassLoader, gFindClassMethod, env->NewStringUTF(name)));
    }

    void setTargetClass(char *targetClassName) {
        JNIEnv *curEnv;
        bool bShouldDetach = false;

        auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
        if (error < 0) {
            error = gJvm->AttachCurrentThread(&curEnv, nullptr);
            bShouldDetach = true;
            NSLog("AttachCurrentThread : %d", error);
        }
        jclass cls = findClass(curEnv, "com/dartnative/dart_native/DartNative");
        NSLog("class name : %s", targetClassName);
        jclass targetClass = findClass(curEnv, targetClassName);
        gTargetClass = curEnv->NewGlobalRef(targetClass);
        if (cls != nullptr) {
            jmethodID method = curEnv->GetStaticMethodID(cls, "setTargetClass", "(Ljava/lang/Class;)V");
            if (method != nullptr) {
                curEnv->CallStaticVoidMethod(cls, method, targetClass);
            }
        }

        if (bShouldDetach) {
            gJvm->DetachCurrentThread();
        }
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

        jclass cls = findClass(curEnv, "com/dartnative/dart_native/DartNative");
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
        void *nativeRunResult = nullptr;

        auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
        if (error < 0) {
            error = gJvm->AttachCurrentThread(&curEnv, nullptr);
            bShouldDetach = true;
            NSLog("AttachCurrentThread : %d", error);
        }

        jclass cls = findClass(curEnv, "com/dartnative/dart_native/DartNative");

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

                    if (strcmp(arrArgTypes[index], "double") == 0) {
                        NSLog("double param : %f", *((double *)args));
                        arrArgs[index] = (double *)args;
                    }

                    if (strcmp(arrArgTypes[index], "float") == 0) {
                        NSLog("float param : %f", *((float *)args));
                        arrArgs[index] = (float *)args;
                    }
                }

                if (strcmp(methodReturnType, "char") == 0) {
                    jmethodID nativeMethod = curEnv->GetStaticMethodID(static_cast<jclass>(gTargetClass), methodName, signature);
                    if (nativeMethod != nullptr) {
                        char *charArg = (char *)arrArgs[0];
                        jchar nativeChar = curEnv->CallStaticCharMethod(static_cast<jclass>(gTargetClass), nativeMethod, (jchar)*charArg);
                        nativeRunResult = (void *)nativeChar;
                    }
                }

                if (strcmp(methodReturnType, "int") == 0) {
                    jmethodID nativeMethod = curEnv->GetStaticMethodID(static_cast<jclass>(gTargetClass), methodName, signature);
                    if (nativeMethod != nullptr) {
                        jint nativeInt = curEnv->CallStaticIntMethod(static_cast<jclass>(gTargetClass), nativeMethod, (jint)*((int *)arrArgs[0]));
                        nativeRunResult = (void *)nativeInt;
                    }
                }

                if (strcmp(methodReturnType, "boolean") == 0) {
                    jmethodID nativeMethod = curEnv->GetStaticMethodID(static_cast<jclass>(gTargetClass), methodName, signature);
                    if (nativeMethod != nullptr) {
                        jint nativeBool = curEnv->CallStaticBooleanMethod(static_cast<jclass>(gTargetClass), nativeMethod, *((int *)arrArgs) ? JNI_TRUE : JNI_FALSE);
                        nativeRunResult = (void *)nativeBool;
                    }
                }

                if (strcmp(methodReturnType, "double") == 0) {
                    jmethodID nativeMethod = curEnv->GetStaticMethodID(static_cast<jclass>(gTargetClass), methodName, signature);
                    if (nativeMethod != nullptr) {
                        jdouble nativeDouble = curEnv->CallStaticDoubleMethod(static_cast<jclass>(gTargetClass), nativeMethod, (jdouble)*((double *)arrArgs[0]));
                        double cDouble = (double) nativeDouble;
                        memcpy(&nativeRunResult, &cDouble, sizeof(double));
                    }
                }

                if (strcmp(methodReturnType, "float") == 0) {
                    jmethodID nativeMethod = curEnv->GetStaticMethodID(static_cast<jclass>(gTargetClass), methodName, signature);
                    if (nativeMethod != nullptr) {
                        jfloat nativeFloat = curEnv->CallStaticFloatMethod(static_cast<jclass>(gTargetClass), nativeMethod, (jfloat)*((float *)arrArgs[0]));
                        float cFloat = (float) nativeFloat;
                        memcpy(&nativeRunResult, &cFloat, sizeof(float));
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

