import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';
import 'package:ffi/ffi.dart';

final Pointer<Void> Function(Pointer<Utf8>) objc_getClass = nativeLib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getClass')
    .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) objc_getMetaClass = nativeLib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getMetaClass')
    .asFunction();

final Pointer<Void> Function(Pointer<Void>) object_getClass = nativeLib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        'object_getClass')
    .asFunction();

final int Function(Pointer<Void>) object_isClass = nativeLib
    .lookup<NativeFunction<Int8 Function(Pointer<Void>)>>(
        'object_isClass')
    .asFunction();

final Pointer<Utf8> Function(Pointer<Void>) class_getName = nativeLib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'class_getName')
    .asFunction();

final Pointer<Utf8> Function(Pointer<Void>) sel_getName = nativeLib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'sel_getName')
    .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) sel_registerName = nativeLib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'sel_registerName')
    .asFunction();
