import 'dart:ffi';

import 'package:dart_native/src/ios/common/library.dart';
import 'package:ffi/ffi.dart';

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Utf8>) objc_getClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getClass')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Utf8>) objc_getMetaClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getMetaClass')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Void>) object_getClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        'object_getClass')
    .asFunction();

// ignore: non_constant_identifier_names
final int Function(Pointer<Void>) object_isClass = nativeDylib
    .lookup<NativeFunction<Int8 Function(Pointer<Void>)>>('object_isClass')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Utf8> Function(Pointer<Void>) class_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'class_getName')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Utf8> Function(Pointer<Void>) sel_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'sel_getName')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Utf8>) sel_registerName = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'sel_registerName')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Utf8>) objc_getProtocol = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getProtocol')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Utf8> Function(Pointer<Void>) protocol_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'protocol_getName')
    .asFunction();

// ignore: non_constant_identifier_names
final Pointer<Void> Function(Pointer<Void>) Block_copy = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        '_Block_copy')
    .asFunction();

// ignore: non_constant_identifier_names
final void Function(Pointer<Void>) Block_release = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void>)>>('_Block_release')
    .asFunction();

final void Function(Object, Pointer<Void>) passObjectToC = nativeDylib
    .lookup<NativeFunction<Void Function(Handle, Pointer<Void>)>>(
        "PassObjectToCUseDynamicLinking")
    .asFunction();
