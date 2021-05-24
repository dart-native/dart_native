import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Map` in Android.
const String CLS_HASH_MAP = "java/util/HashMap";

class JMap extends JSubclass<Map> {
  JMap(Map value, {String clsName: CLS_HASH_MAP, InitSubclass init: _new}) : super(value, _new, clsName) {
    value = Map.of(value);
  }

  JMap.fromPointer(Pointer<Void> ptr, {String clsName: CLS_HASH_MAP}) : super.fromPointer(ptr, clsName) {
    Set keySet = JSet.fromPointer(invoke("keySet", [], "Ljava/util/Set;")).raw;
    Map temp = {};
    String itemType = "";
    print("map key set ${keySet.toString()}");
    for (var key in keySet) {
      Pointer<Void> itemPtr = invoke("get", [boxingWrapperClass(key)], "Ljava/lang/Object;", [_argSignature]);
      if (itemType == "") {
        itemType = _getItemClass(itemPtr);
      }
      temp[key] = unBoxingWrapperClass(itemPtr, itemType);
    }
    raw = temp;
  }
}

Pointer<Utf8> _argSignature = Utf8.toUtf8("Ljava/lang/Object;");

/// New native 'HashMap'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Map) {
    ///'Map' default implementation 'HashMap'.
    JObject nativeMap = JObject(clsName);

    if (value == null) {
      return nativeMap.pointer;
    }
    value.forEach((key, value) {
      nativeMap.invoke("put", [boxingWrapperClass(key), boxingWrapperClass(value)], "Ljava/lang/Object;", [_argSignature, _argSignature]);
    });
    return nativeMap.pointer;
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
