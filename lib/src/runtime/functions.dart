import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';
import 'package:ffi/ffi.dart';

final Pointer<Void> Function(Pointer<Utf8>) objc_getClass = nativeLib
    .lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'objc_getClass')
    .asFunction();
