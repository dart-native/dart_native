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
    String itemType = "";
    for (var i = 0; i < count; i++) {
      Pointer<Void> itemPtr = invoke("get", [i], "Ljava/lang/Object;");
      if (itemType == "") {
        itemType = _getItemClass(itemPtr);
      }
      temp[i] = unBoxingWrapperClass(itemPtr, itemType);
    }
    raw = temp;
  }
}

Pointer<Utf8> _argSignature = Utf8.toUtf8("Ljava/lang/Object;");

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == CLS_LIST) clsName = CLS_ARRAYLIST;

    JObject nativeList = JObject(clsName);

    if (value == null) {
      return nativeList.pointer;
    }
    for (var i = 0; i < value.length; i ++) {
      nativeList.invoke("add", [boxingWrapperClass(value[i])], "Z", [_argSignature]);
    }
    return nativeList.pointer;
  } else {
    throw 'Invalid param when initializing JList.';
  }
}

String _getItemClass(Pointer<Void> itemPtr) {
  JObject templeObject = JObject("java/lang/Object", itemPtr);
  templeObject = JObject("java/lang/Class",
      templeObject.invoke("getClass", null, "Ljava/lang/Class;"));
  
  return templeObject.invoke("getName", null, "Ljava/lang/String;");
}
