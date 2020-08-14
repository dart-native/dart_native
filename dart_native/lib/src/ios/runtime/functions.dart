import 'dart:ffi';

import 'package:dart_native/src/ios/common/library.dart';
import 'package:ffi/ffi.dart';

final Pointer<Void> Function(Pointer<Utf8>) objc_getClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getClass')
    .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) objc_getMetaClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getMetaClass')
    .asFunction();

final Pointer<Void> Function(Pointer<Void>) object_getClass = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        'object_getClass')
    .asFunction();

final int Function(Pointer<Void>) object_isClass = nativeDylib
    .lookup<NativeFunction<Int8 Function(Pointer<Void>)>>('object_isClass')
    .asFunction();

final Pointer<Utf8> Function(Pointer<Void>) class_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'class_getName')
    .asFunction();

final Pointer<Utf8> Function(Pointer<Void>) sel_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'sel_getName')
    .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) sel_registerName = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'sel_registerName')
    .asFunction();

final Pointer<Void> Function(Pointer<Utf8>) objc_getProtocol = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getProtocol')
    .asFunction();

final Pointer<Utf8> Function(Pointer<Void>) protocol_getName = nativeDylib
    .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Void>)>>(
        'protocol_getName')
    .asFunction();

final Pointer<Void> Function(Pointer<Void>) Block_copy = nativeDylib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Void>)>>(
        '_Block_copy')
    .asFunction();

final void Function(Pointer<Void>) Block_release = nativeDylib
    .lookup<NativeFunction<Void Function(Pointer<Void>)>>('_Block_release')
    .asFunction();

final Object Function(Object) passObjectToC = nativeDylib
    .lookup<NativeFunction<Handle Function(Handle)>>(
        "PassObjectToCUseDynamicLinking")
    .asFunction();
