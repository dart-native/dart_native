import 'dart:ffi';

import 'package:dart_native/src/android/common/library.dart';
import 'package:ffi/ffi.dart';

typedef NativeMethodType = Pointer<Utf8> Function(Pointer<Utf8> signature);
final NativeMethodType nativeMethodType =
nativeDylib.lookupFunction<NativeMethodType, NativeMethodType>('nativeMethodType');

typedef NativeMethod = Pointer<Void> Function(Pointer<Utf8> signature);
final NativeMethod nativeMethod =
nativeDylib.lookupFunction<NativeMethod, NativeMethod>('nativeMethod');

typedef InvokeNativeMethod = Pointer<Void> Function(Pointer<Utf8> methodName, Pointer<Pointer<Void>> args);
final InvokeNativeMethod invokeNativeMethod =
nativeDylib.lookupFunction<InvokeNativeMethod, InvokeNativeMethod>('invokeNativeMethod');

typedef SetTargetClass = Pointer<Void> Function(Pointer<Utf8> className);
final SetTargetClass targetClass =
nativeDylib.lookupFunction<SetTargetClass, SetTargetClass>('setTargetClass');