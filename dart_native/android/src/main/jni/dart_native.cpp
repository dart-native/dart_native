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

static jbyteArray gJbyteArray;
char* paramsBuffer;
int paramsBufferLength = 0;

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
    NSLog("west JNI_OnLoad");
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

    NSLog("west JNI_OnLoad finish");
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



void *generateParamBuffer(int* size) {
    paramsBuffer = (char*)malloc(*size);
    paramsBufferLength = *size;
    return (void *)paramsBuffer;
}


static jclass gStringClass;
static jmethodID gStringMethod;
jstring toJstring(char * stringArg, JNIEnv *curEnv){
    if(gStringClass == NULL){
        gStringClass = curEnv->FindClass("java/lang/String");
        gStringMethod = curEnv->GetMethodID(gStringClass, "<init>","([BLjava/lang/String;)V");
    }

    jbyteArray bytes = curEnv->NewByteArray(strlen(stringArg));
    curEnv->SetByteArrayRegion(bytes, 0, strlen(stringArg), (jbyte *) stringArg);
    jstring encoding = curEnv->NewStringUTF("utf-8");

    jstring result = (jstring) curEnv->NewObject(gStringClass, gStringMethod, bytes, encoding);

    curEnv->DeleteLocalRef(bytes);
    curEnv->DeleteLocalRef(encoding);
    return result;
}

void* newJavaObject(char *className) {
    JNIEnv *curEnv;

    NSLog("west newJavaObject1:%s", className);

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        NSLog("west AttachCurrentThread : %d", error);
    }

    jstring classNameJstr = toJstring(className, curEnv);

    //找到相关的类 注意路径是带反斜杆  不是带.
    jclass cls_First = findClass(curEnv, "com/dartnative/dart_native_example/FlutterJavaBridge");
    if(cls_First == NULL){
        return NULL;
    }

    /**
    方法参数：类名，方法名，方法签名
    */
    //找到对应的方法  注意签名后面有冒号
    jmethodID mtd_static_method = curEnv->GetStaticMethodID(cls_First,"newObject","(Ljava/lang/String;[B)I");
    if(mtd_static_method == NULL){
        NSLog("west mtd_static_method null");
        return NULL;
    }


    //参数
    gJbyteArray = curEnv->NewByteArray(paramsBufferLength);
    curEnv->SetByteArrayRegion(gJbyteArray, 0, paramsBufferLength, (jbyte *) paramsBuffer);

    //调用java层静态方法
    auto hashCode =
            curEnv->CallStaticIntMethod(cls_First, mtd_static_method, classNameJstr, gJbyteArray);

    //删除引用
    curEnv->DeleteLocalRef(cls_First);
    curEnv->DeleteLocalRef(gJbyteArray);
    curEnv->DeleteLocalRef(classNameJstr);

    return (void*)hashCode;
}


static jclass gFlutterJavaBirdgeClass;
static jmethodID gFlutterJavaInvokeMethod;
void *invokeJavaMethod(int* javaObjectHashCode, char *methodName) {
    JNIEnv *curEnv;

    auto error = gJvm->GetEnv((void **) &curEnv, JNI_VERSION_1_6);
    if (error < 0) {
        error = gJvm->AttachCurrentThread(&curEnv, nullptr);
        NSLog("west AttachCurrentThread : %d", error);
    }

    //找到相关的类 注意路径是带反斜杆  不是带.
    if(gFlutterJavaBirdgeClass == NULL){
        gFlutterJavaBirdgeClass = findClass(curEnv, "com/dartnative/dart_native_example/FlutterJavaBridge");
    }

    if(gFlutterJavaBirdgeClass == NULL){
        NSLog("west can not find class FlutterJavaBridge");
        return NULL;
    }

    if(gFlutterJavaInvokeMethod == NULL){
        //找到对应的方法  注意签名后面有冒号
        gFlutterJavaInvokeMethod = curEnv->GetStaticMethodID(gFlutterJavaBirdgeClass,"invoke","(ILjava/lang/String;[B)[B");

    }

    if(gFlutterJavaInvokeMethod == NULL){
        NSLog("west not find method : invoke");
        return NULL;
    }

    gJbyteArray = curEnv->NewByteArray(paramsBufferLength);
    curEnv->SetByteArrayRegion(gJbyteArray, 0, paramsBufferLength, (jbyte *) paramsBuffer);
    jstring methodNameStr = toJstring(methodName, curEnv);

    //调用java层静态方法
    jbyteArray resultBuffer = static_cast<jbyteArray>(curEnv ->CallStaticObjectMethod(gFlutterJavaBirdgeClass,gFlutterJavaInvokeMethod,(jint) *((int *) javaObjectHashCode),methodNameStr, gJbyteArray));

    if(resultBuffer == NULL){
        NSLog("west resultBuffer is NULL");
        return NULL;
    }

    jbyte * bytePointer  = curEnv->GetByteArrayElements(resultBuffer, 0);

    //删除引用
    curEnv->DeleteLocalRef(gJbyteArray);
    curEnv->DeleteLocalRef(methodNameStr);
    curEnv->DeleteLocalRef(resultBuffer);

    return bytePointer;

}


void *releaseParamBuffer() {
    free(paramsBuffer);
    return NULL;
}

}

