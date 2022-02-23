import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Array in Android.
const String jArrayCls = 'java/lang/Object';

@native(javaClass: jArrayCls)
class JArray<E> extends JSubclass<List> {
  String get arraySignature => _arraySignature;
  String _arraySignature = '[Ljava/lang/Object;';

  JArray(List value) : super(value, _new, jArrayCls) {
    value = List.of(value, growable: false);
    if (value.isNotEmpty) {
      ArrayType type = _getValueType(value[0]);
      _arraySignature = type.arraySignature;
    }
  }

  JArray.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr, jArrayCls) {
    JObject converter =
        JObject(className: 'com/dartnative/dart_native/ArrayListConverter');
    raw = JList<E>.fromPointer(converter.invoke(
        'arrayToList', 'Ljava/util/List;',
        args: [JObject.fromPointer(ptr, className: 'java/lang/Object')])).raw;
  }
}

Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    JObject converter =
        JObject(className: 'com/dartnative/dart_native/ArrayListConverter');
    JList list = JList(value);
    ArrayType type = ArrayType('object', '[Ljava/lang/Object;');
    if (value.isNotEmpty) {
      type = _getValueType(value[0]);
    }
    return converter.invoke('${type.arrayType}ListToArray', type.arraySignature,
        args: [list]);
  } else {
    throw 'Invalid param when initializing JArray.';
  }
}

ArrayType _getValueType(dynamic value) {
  if (value is byte) {
    return ArrayType('byte', '[B');
  } else if (value is short) {
    return ArrayType('short', '[S');
  } else if (value is long) {
    return ArrayType('long', '[J');
  } else if (value is char) {
    return ArrayType('char', '[C');
  } else if (value is int) {
    return ArrayType('int', '[I');
  } else if (value is float) {
    return ArrayType('float', '[F');
  } else if (value is double) {
    return ArrayType('double', '[D');
  } else if (value is bool) {
    return ArrayType('bool', '[Z');
  } else if (value is JObject) {
    return ArrayType('object', '[L' + value.className! + ';');
  } else {
    throw 'Invalid type in JArray.';
  }
}

class ArrayType {
  String arrayType;
  String arraySignature;

  ArrayType(this.arrayType, this.arraySignature);
}
