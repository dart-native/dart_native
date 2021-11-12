import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `List` in Android.
const String cls_list = "java/util/List";
const String cls_array_list = "java/util/ArrayList";

class JList extends JSubclass<List> {
  JList(List value, {String clsName: cls_list, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr, {String clsName: cls_list})
      : super.fromPointer(ptr, clsName) {
    int count = invoke("size", [], "I");
    List temp = List.filled(count, nullptr, growable: false);
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

class JArrayList extends JList {
  JArrayList(List value) : super(value, clsName: cls_array_list);

  JArrayList.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: cls_array_list);
}

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == cls_list) clsName = cls_array_list;

    JObject nativeList = JObject(clsName);

    Pointer<Utf8> argSignature = "Ljava/lang/Object;".toNativeUtf8();
    for (var i = 0; i < value.length; i++) {
      nativeList.invoke("add", [boxingWrapperClass(value[i])], "Z",
          argsSignature: [argSignature]);
    }
    calloc.free(argSignature);
    return nativeList.pointer.cast<Void>();
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
