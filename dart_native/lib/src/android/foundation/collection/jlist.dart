import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `List` in Android. Default implementation is 'ArrayList'.
const String clsArrayList = "java/util/ArrayList";
class JList extends JSubclass<List> {
  JList(List value, {String clsName: clsArrayList, InitSubclass init: _new}) : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr, {String clsName: clsArrayList}) : super.fromPointer(ptr, clsArrayList) {
    int count = invoke("size", [""], "I");
    List temp = List(count);
    for (var i = 0; i < count; i++) {
      temp[i] = invoke("get", [i], "Ljava/lang/Object;");
    }
    raw = temp;
  }

}

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    JObject nativeList = JObject(clsName);
    Pointer<Utf8> argSignature = Utf8.toUtf8("Ljava/lang/Object;");
    if (value != null) {
      for (var i = 0; i < value.length; i ++) {
        nativeList.invoke("add", [value[i]], "Z", [argSignature]);
      }
    }
    return nativeList.pointer;
  } else {
    throw 'Invalid param when initializing JList.';
  }
}