import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

///==============================================
/// 创建native class
/// input : className
/// return : classObject
final Pointer<Void> Function(Pointer<Utf8>) nativeCreateClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        "createTargetClass")
    .asFunction();

/// release class
/// objectPtr: 对象指针
final void Function(Pointer<Void> objectPtr) nativeReleaseClass = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void> objectPtr)>>(
    "releaseTargetClass")
    .asFunction();

/// 调用native方法
///
/// @param:
/// objectPtr: 对象指针
/// methodPtr: 方法名称
/// argsPtr: 参数指针list
/// jniMethodSignature: jni函数指针
///
/// @return: 返回值指针
final Pointer<Void> Function(Pointer<Void> objectPtr, Pointer<Utf8> methodName,
        Pointer<Pointer<Void>> argsPtrs, Pointer<Utf8> jniMethodSignature)
    nativeInvoke = nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Void> objectPtr,
                    Pointer<Utf8> methodName,
                    Pointer<Pointer<Void>> argsPtrs,
                    Pointer<Utf8> jniMethodSignature)>>("invokeNativeMethod")
        .asFunction();

/// 获取参数序列化的内存地址
///
/// @return: 返回值指针
final Pointer<Void> Function(Pointer<Int32>)
    generateParamBuffer = nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Int32>)>>("generateParamBuffer")
        .asFunction();



/// 获取参数序列化的内存地址
///
/// @return: 返回值指针
final Pointer<Void> Function()
    releaseParamBuffer = nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function()>>("releaseParamBuffer")
        .asFunction();

/// 调用native方法, 创建一个native对象
///
/// @param:
/// className: 需要调用的class名字
/// @return: 返回java对象引用的hashcode
final Pointer<Void> Function(Pointer<Utf8> className)
newJavaObject = nativeDylib
    .lookup<
    NativeFunction<
        Pointer<Void> Function(Pointer<Utf8> className)>>("newJavaObject")
    .asFunction();




/// 调用native方法
///
/// @param:
/// className: 需要调用的class名字
/// methodName: 方法名称
/// argsPtr: 参数指针list
///
/// @return: 返回值指针
final Pointer<Void> Function(Pointer<Int32> javaObjectHashCode, Pointer<Utf8> methodName)
    invokeJavaMethod = nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Int32> javaObjectHashCode, Pointer<Utf8> methodName)>>("invokeJavaMethod")
        .asFunction();
