import 'dart:ffi';


import 'package:dart_native/src/common/native_dylib.dart';
import 'package:ffi/ffi.dart';

typedef DartFinalizerFunction = void Function();

extension DartFinalizer on Object {
  void addFinalizer(DartFinalizerFunction function) {
    Pointer<Void> key = calloc<Uint64>().cast();
    _finalizers[key] = function;
    _registerDartFinalizer(this, _commonFinalizerPtr.cast(), key, nativePort);
  }
}

void _commonFinalizer(Pointer<Void> key) {
  final function = _finalizers[key];
  function?.call();
  _finalizers.remove(key);
  malloc.free(key);
}

Pointer<NativeFunction<Void Function(Pointer<Void>)>> _commonFinalizerPtr =
    Pointer.fromFunction(_commonFinalizer);

Map<Pointer<Void>, DartFinalizerFunction> _finalizers = {};

typedef _RegisterDartFinalizerC = Void Function(
    Handle, Pointer<Void>, Pointer<Void>, Int64);
typedef _RegisterDartFinalizerD = void Function(
    Object, Pointer<Void>, Pointer<Void>, int);
final _RegisterDartFinalizerD _registerDartFinalizer = nativeDylib
    .lookupFunction<_RegisterDartFinalizerC, _RegisterDartFinalizerD>(
        'RegisterDartFinalizer');
