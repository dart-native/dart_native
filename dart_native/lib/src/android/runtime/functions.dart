import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

typedef MethodNativeCallback = Void Function(
    Pointer<Utf8> test
    );

///==============================================
/// 创建native class
/// input : className
/// return : classObject
final Pointer<Void> Function(Pointer<Utf8>) nativeCreateClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        "createTargetClass")
    .asFunction();

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
final Pointer<Void> Function(Pointer<Void> objectPtr, Pointer<Utf8> methodName,
    Pointer<Pointer<Void>> argsPtrs, Pointer<Pointer<Utf8>> typePtrs, Pointer<Utf8> returnType)
nativeInvokeNeo = nativeDylib
    .lookup<
    NativeFunction<
        Pointer<Void> Function(
            Pointer<Void> objectPtr,
            Pointer<Utf8> methodName,
            Pointer<Pointer<Void>> argsPtrs,
            Pointer<Pointer<Utf8>> typePtrs,
            Pointer<Utf8> returnType)>>("invokeNativeMethodNeo")
    .asFunction();

final void Function(Object, Pointer<Void>) passJObjectToC = nativeDylib
    .lookup<NativeFunction<Void Function(Handle, Pointer<Void>)>>(
    "PassObjectToCUseDynamicLinking")
    .asFunction();

final void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Pointer<NativeFunction<MethodNativeCallback>>)
  registerNativeCallback = nativeDylib
    .lookup<
    NativeFunction<
        Void Function(
            Pointer<Void> targetPtr,
            Pointer<Utf8> targetName,
            Pointer<Utf8> funName,
            Pointer<NativeFunction<MethodNativeCallback>> funcation)>>("registerNativeCallback")
    .asFunction();
