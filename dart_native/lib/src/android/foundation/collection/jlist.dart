import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `List` in Android.
const String CLS_LIST = "java/util/List";
const String CLS_ARRAYLIST = "java/util/ArrayList";

class JList extends JSubclass<List> {
  JList(List value, {String clsName: CLS_LIST, InitSubclass init: _new}) : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr, {String clsName: CLS_LIST}) : super.fromPointer(ptr, clsName) {
    int count = invoke("size", [], "I");
    List temp = List(count);
    for (var i = 0; i < count; i++) {
      temp[i] = Integer.fromPointer(invoke("get", [i], "Ljava/lang/Object;")).raw;
    }
    raw = temp;
  }

}

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == CLS_LIST) clsName = CLS_ARRAYLIST;

    JObject nativeList = JObject(clsName);
    Pointer<Utf8> argSignature = Utf8.toUtf8("Ljava/lang/Object;");

    if (value == null) {
      return nativeList.pointer;
    }

    for (var i = 0; i < value.length; i ++) {
      nativeList.invoke("add", [Integer(value[i])], "Z", [argSignature]);
    }
    return nativeList.pointer;
  } else {
    throw 'Invalid param when initializing JList.';
  }
}