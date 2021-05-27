import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

typedef MethodNativeCallback = Void Function(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    Int32 argCount);

///==============================================
/// 创建native class
/// input : className
/// return : classObject
final Pointer<Void> Function(
        Pointer<Utf8> clsName,
        Pointer<Pointer<Void>> argsPtrs,
        Pointer<Pointer<Utf8>> typePtrs,
        int argCount) nativeCreateClass =
    nativeDylib
        ?.lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Utf8> clsName,
                    Pointer<Pointer<Void>> argsPtrs,
                    Pointer<Pointer<Utf8>> typePtrs,
                    Int32 argCount)>>("createTargetClass")
        ?.asFunction();

/// 调用native方法
///
/// @param:
/// objectPtr: 对象指针
/// methodPtr: 方法名称
/// argsPtr: 参数指针list
/// typePtr: 参数类型指针list
/// returnType: 需要的返回类型指针
///
/// @return: 返回值指针
final Pointer<Void> Function(
        Pointer<Void> objectPtr,
        Pointer<Utf8> methodName,
        Pointer<Pointer<Void>> argsPtrs,
        Pointer<Pointer<Utf8>> typePtrs,
        int argCount,
        Pointer<Utf8> returnType) nativeInvokeNeo =
    nativeDylib
        ?.lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Void> objectPtr,
                    Pointer<Utf8> methodName,
                    Pointer<Pointer<Void>> argsPtrs,
                    Pointer<Pointer<Utf8>> typePtrs,
                    Int32 argCount,
                    Pointer<Utf8> returnType)>>("invokeNativeMethodNeo")
        ?.asFunction();

///
/// dart对象与native对象绑定
///
final void Function(Object, Pointer<Void>) passJObjectToC = nativeDylib
    ?.lookup<NativeFunction<Void Function(Handle, Pointer<Void>)>>(
        "PassObjectToCUseDynamicLinking")
    ?.asFunction();

///
/// 注册异步回调函数
///
final void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<NativeFunction<MethodNativeCallback>>, int)
    registerNativeCallback = nativeDylib
        ?.lookup<
            NativeFunction<
                Void Function(
                    Pointer<Void> targetPtr,
                    Pointer<Utf8> targetName,
                    Pointer<Utf8> funName,
                    Pointer<NativeFunction<MethodNativeCallback>> funcation,
                    Int64 dartPort)>>("registerNativeCallback")
        ?.asFunction();

///
/// convert dart string to java string with utf16
///
final Pointer<Void> Function(Pointer<Uint16>, int) dartStringToJavaString =
    nativeDylib
        ?.lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Uint16> utf16String,
                    Int64 length)>>("dartStringToJavaString")
        ?.asFunction();

///
/// convert java string to dart string with utf16
///
final Pointer<Void> Function(Pointer<Void>, Pointer<Uint64>)
    javaStringToDartString = nativeDylib
        ?.lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Void> utf16String,
                    Pointer<Uint64> length)>>("javaStringToDartString")
        ?.asFunction();
