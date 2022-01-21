import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/internal/native_runtime.dart';
import 'package:ffi/ffi.dart';

extension TypeEncodings on Pointer<Utf8> {
  static final Pointer<Pointer<Utf8>> _typeEncodings = nativeAllTypeEncodings();
  static final Pointer<Utf8> sint8 = _typeEncodings.elementAt(0).value;
  static final Pointer<Utf8> sint16 = _typeEncodings.elementAt(1).value;
  static final Pointer<Utf8> sint32 = _typeEncodings.elementAt(2).value;
  static final Pointer<Utf8> sint64 = _typeEncodings.elementAt(3).value;
  static final Pointer<Utf8> uint8 = _typeEncodings.elementAt(4).value;
  static final Pointer<Utf8> uint16 = _typeEncodings.elementAt(5).value;
  static final Pointer<Utf8> uint32 = _typeEncodings.elementAt(6).value;
  static final Pointer<Utf8> uint64 = _typeEncodings.elementAt(7).value;
  static final Pointer<Utf8> float32 = _typeEncodings.elementAt(8).value;
  static final Pointer<Utf8> float64 = _typeEncodings.elementAt(9).value;
  static final Pointer<Utf8> object = _typeEncodings.elementAt(10).value;
  static final Pointer<Utf8> cls = _typeEncodings.elementAt(11).value;
  static final Pointer<Utf8> selector = _typeEncodings.elementAt(12).value;
  static final Pointer<Utf8> block = _typeEncodings.elementAt(13).value;
  static final Pointer<Utf8> cstring = _typeEncodings.elementAt(14).value;
  static final Pointer<Utf8> v = _typeEncodings.elementAt(15).value;
  static final Pointer<Utf8> pointer = _typeEncodings.elementAt(16).value;
  static final Pointer<Utf8> b = _typeEncodings.elementAt(17).value;
  static final Pointer<Utf8> string = _typeEncodings.elementAt(18).value;

  // Return encoding only if type is struct.
  String? get encodingForStruct {
    if (isStruct) {
      return toDartString();
    }
    return null;
  }

  bool get isStruct {
    // ascii for '{' is 123.
    return cast<Uint8>().value == 123;
  }

  bool get isString {
    return this == TypeEncodings.string;
  }

  bool get isNum {
    bool result = this == TypeEncodings.sint8 ||
        this == TypeEncodings.sint16 ||
        this == TypeEncodings.sint32 ||
        this == TypeEncodings.sint64 ||
        this == TypeEncodings.uint8 ||
        this == TypeEncodings.uint16 ||
        this == TypeEncodings.uint32 ||
        this == TypeEncodings.uint64 ||
        this == TypeEncodings.float32 ||
        this == TypeEncodings.float64;
    return result;
  }

  bool get maybeObject {
    return this == TypeEncodings.pointer || this == TypeEncodings.object;
  }

  bool get maybeBlock {
    return this == TypeEncodings.block || maybeObject;
  }

  bool get maybeId {
    return this == TypeEncodings.cls || maybeBlock;
  }

  bool get maybeSEL {
    return this == TypeEncodings.selector || this == TypeEncodings.pointer;
  }

  bool get maybeCString {
    return this == TypeEncodings.cstring || this == TypeEncodings.pointer;
  }
}
