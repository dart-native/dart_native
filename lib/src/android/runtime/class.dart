import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

class Class {
  String _className;

  Class(String className) {
    _className = className;
  }

  Pointer<Utf8> classUtf8() {
    return Utf8.toUtf8(_className);
  }
}
