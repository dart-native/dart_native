import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Map` in Android.
const String cls_map = 'java/util/Map';
const String cls_hash_map = 'java/util/HashMap';

@nativeJavaClass(cls_map)
class JMap<K, V> extends JSubclass<Map> {
  JMap(Map value, {String clsName = cls_map, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = Map.of(value);
  }

  JMap.fromPointer(Pointer<Void> ptr, {String clsName = cls_map})
      : super.fromPointer(ptr, clsName) {
    Set keySet = JSet<K>.fromPointer(invoke('keySet', 'Ljava/util/Set;')).raw;
    Map temp = {};
    String itemType = '';
    for (var key in keySet) {
      dynamic item = invoke('get', 'Ljava/lang/Object;',
          args: [boxingWrapperClass(key)],
          assignedSignature: ['Ljava/lang/Object;']);
      final valueConvertor = getRegisterPointerConvertor(V.toString());
      if (valueConvertor != null) {
        temp[key] = valueConvertor(item);
        continue;
      }
      if (itemType == '') {
        if (item is String) {
          itemType = 'java/lang/String';
        } else {
          itemType = getJClassName(item);
        }
      }
      temp[key] = unBoxingWrapperClass(item, itemType);
    }
    raw = temp;
  }
}

@nativeJavaClass(cls_hash_map)
class JHashMap<K, V> extends JMap {
  JHashMap(Map value) : super(value, clsName: cls_hash_map);

  JHashMap.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: cls_hash_map);
}

/// New native 'HashMap'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Map) {
    ///'Map' default implementation 'HashMap'.
    if (clsName == cls_map) clsName = cls_hash_map;

    JObject nativeMap = JObject(className: clsName);
    value.forEach((key, value) {
      nativeMap.invoke('put', 'Ljava/lang/Object;',
          args: [boxingWrapperClass(key), boxingWrapperClass(value)],
          assignedSignature: ['Ljava/lang/Object;', 'Ljava/lang/Object;']);
    });
    return nativeMap.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JList.';
  }
}
