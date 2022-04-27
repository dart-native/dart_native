import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

// use in dart callback and interface
typedef MethodNativeCallback = Void Function(
    Pointer<Void> targetPtr,
    Pointer<Utf8> funNamePtr,
    Pointer<Pointer<Void>> argsPtrPtr,
    Pointer<Pointer<Utf8>> argTypesPtrPtr,
    Int32 argCount,
    Int32 shouldReturnAsync);

// use in async invoke
typedef InvokeCallback = Void Function(Pointer<Void> result,
    Pointer<Utf8> method, Pointer<Pointer<Utf8>> typePointers, Int32 argCount);

// create java object
final Pointer<Void> Function(
        Pointer<Utf8> clsName,
        Pointer<Pointer<Void>> argsPtrs,
        Pointer<Pointer<Utf8>> typePtrs,
        int argCount,
        int stringTypeBitmask) nativeCreateObject =
    nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Utf8> clsName,
                    Pointer<Pointer<Void>> argsPtrs,
                    Pointer<Pointer<Utf8>> typePtrs,
                    Int32 argCount,
                    Uint32 stringTypeBitmask)>>('CreateTargetObject')
        .asFunction();

// invoke java method
final Pointer<Void> Function(
        Pointer<Void> objectPtr,
        Pointer<Utf8> methodName,
        Pointer<Pointer<Void>> argsPtrs,
        Pointer<Pointer<Utf8>> typePtrs,
        int argCount,
        Pointer<Utf8> returnType,
        int stringTypeBitmask,
        Pointer<NativeFunction<InvokeCallback>>,
        int dartPort,
        int thread,
        bool isInterface) nativeInvoke =
    nativeDylib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Void> objectPtr,
                    Pointer<Utf8> methodName,
                    Pointer<Pointer<Void>> argsPtrs,
                    Pointer<Pointer<Utf8>> typePtrs,
                    Int32 argCount,
                    Pointer<Utf8> returnType,
                    Uint32 stringTypeBitmask,
                    Pointer<NativeFunction<InvokeCallback>>,
                    Int64 dartPort,
                    Int32 thread,
                    Bool isInterface)>>('InvokeNativeMethod')
        .asFunction();

// bind dart object lifecycle with java object
final void Function(Object, Pointer<Void>) passJObjectToC = nativeDylib
    .lookup<NativeFunction<Void Function(Handle, Pointer<Void>)>>(
        'PassObjectToCUseDynamicLinking')
    .asFunction();

// register callback in java side
final void Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>,
        Pointer<NativeFunction<MethodNativeCallback>>, int)
    registerNativeCallback = nativeDylib
        .lookup<
            NativeFunction<
                Void Function(
                    Pointer<Void> dartObject,
                    Pointer<Utf8> clsName,
                    Pointer<Utf8> funName,
                    Pointer<NativeFunction<MethodNativeCallback>> function,
                    Int64 dartPort)>>('RegisterNativeCallback')
        .asFunction();

// unregisterCallback in java side
final void Function(Pointer<Void>) unregisterNativeCallback = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void> dartObject)>>(
        'UnregisterNativeCallback')
    .asFunction();

// Get java class name from native.
final Pointer<Void> Function(Pointer<Void>) getJavaClassName = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        'GetClassName')
    .asFunction();
