import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Map` in Android.
const String cls_map = "java/util/Map";
const String cls_hash_map = "java/util/HashMap";

class JMap<K, V> extends JSubclass<Map> {
  JMap(Map value, {String clsName: cls_map, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = Map.of(value);
  }

  JMap.fromPointer(Pointer<Void> ptr,
      {String clsName: cls_map,
      K Function(Pointer pointer)? keyCreator,
      V Function(Pointer pointer)? valueCreator})
      : super.fromPointer(ptr, clsName) {
    Set keySet = JSet.fromPointer(invoke("keySet", [], "Ljava/util/Set;"),
            creator: keyCreator)
        .raw;
    Map temp = {};
    String itemType = "";
    Pointer<Utf8> argSignature = "Ljava/lang/Object;".toNativeUtf8();
    for (var key in keySet) {
      dynamic item = invoke(
          "get", [boxingWrapperClass(key)], "Ljava/lang/Object;",
          argsSignature: [argSignature]);
      if (itemType == "") {
        if (item is String) {
          itemType = "java.lang.String";
        } else {
          itemType = _getItemClass(item);
        }
      }
      if (valueCreator != null) {
        valueCreator(item);
      } else {
        temp[key] = unBoxingWrapperClass(item, itemType);
      }
    }
    calloc.free(argSignature);
    raw = temp;
  }
}

class JHashMap<K, V> extends JMap {
  JHashMap(Map value) : super(value, clsName: cls_hash_map);

  JHashMap.fromPointer(Pointer<Void> ptr,
      {K Function(Pointer pointer)? keyCreator,
      V Function(Pointer pointer)? valueCreator})
      : super.fromPointer(ptr,
            clsName: cls_hash_map,
            keyCreator: keyCreator,
            valueCreator: valueCreator);
}

/// New native 'HashMap'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Map) {
    ///'Map' default implementation 'HashMap'.
    if (clsName == cls_map) clsName = cls_hash_map;

    JObject nativeMap = JObject(clsName);
    Pointer<Utf8> argSignature = "Ljava/lang/Object;".toNativeUtf8();
    value.forEach((key, value) {
      nativeMap.invoke(
          "put",
          [boxingWrapperClass(key), boxingWrapperClass(value)],
          "Ljava/lang/Object;",
          argsSignature: [argSignature, argSignature]);
    });
    calloc.free(argSignature);
    return nativeMap.pointer.cast<Void>();
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
