import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `List` in Android.
const String CLS_LIST = "java/util/List";
const String CLS_ARRAY_LIST = "java/util/ArrayList";

class JList extends JSubclass<List> {
  JList(List value, {String clsName: CLS_LIST, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr, {String clsName: CLS_LIST})
      : super.fromPointer(ptr, clsName) {
    int count = invoke("size", [], "I");
    List temp = List(count);
    String itemType = "";
    for (var i = 0; i < count; i++) {
      dynamic item = invoke("get", [i], "Ljava/lang/Object;");
      if (itemType == "") {
        if (item is String) {
          itemType = "java.lang.String";
        } else {
          itemType = _getItemClass(item);
        }
      }
      temp[i] = unBoxingWrapperClass(item, itemType);
    }
    raw = temp;
  }
}

Pointer<Utf8> _argSignature = Utf8.toUtf8("Ljava/lang/Object;");

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == CLS_LIST) clsName = CLS_ARRAY_LIST;

    JObject nativeList = JObject(clsName);

    if (value == null) {
      return nativeList.pointer;
    }
    for (var i = 0; i < value.length; i++) {
      nativeList.invoke("add", [boxingWrapperClass(value[i])], "Z",
          argsSignature: [_argSignature]);
    }
    return nativeList.pointer;
  } else {
    throw 'Invalid param when initializing JList.';
  }
}

String _getItemClass(Pointer<Void> itemPtr) {
  JObject templeObject = JObject("java/lang/Object", pointer: itemPtr);
  templeObject = JObject("java/lang/Class",
      pointer: templeObject.invoke("getClass", null, "Ljava/lang/Class;"));

  return templeObject.invoke("getName", null, "Ljava/lang/String;");
}
