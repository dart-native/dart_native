import 'dart:ffi';

import 'package:ffi/ffi.dart';

class Class extends Comparable<dynamic>{
  String _className;

  Class(String className) {
    _className = className;
  }

  Pointer<Utf8> classUtf8() {
    return Utf8.toUtf8(_className);
  }

  @override
  int compareTo(other) {
    if (other is Class && other._className == _className) {
      return 0;
    }
    return 1;
  }
}