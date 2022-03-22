import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Map` in Android.
const String jMapCls = 'java/util/Map';
const String jHashMapCls = 'java/util/HashMap';

@native(javaClass: jMapCls)
class JMap<K, V> extends JSubclass<Map> {
  JMap(Map value, {String clsName = jMapCls, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = Map.of(value);
  }

  JMap.fromPointer(Pointer<Void> ptr, {String clsName = jMapCls})
      : super.fromPointer(ptr, clsName) {
    Set keySet = JSet<K>.fromPointer(callMethodSync('keySet', 'Ljava/util/Set;')).raw;
    Map temp = {};
    String itemType = '';
    for (var key in keySet) {
      dynamic item = callMethodSync('get', 'Ljava/lang/Object;',
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

@native(javaClass: jHashMapCls)
class JHashMap<K, V> extends JMap {
  JHashMap(Map value) : super(value, clsName: jHashMapCls);

  JHashMap.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: jHashMapCls);
}

/// New native 'HashMap'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Map) {
    ///'Map' default implementation 'HashMap'.
    if (clsName == jMapCls) clsName = jHashMapCls;

    JObject nativeMap = JObject(className: clsName);
    value.forEach((key, value) {
      nativeMap.callMethodSync('put', 'Ljava/lang/Object;',
          args: [boxingWrapperClass(key), boxingWrapperClass(value)],
          assignedSignature: ['Ljava/lang/Object;', 'Ljava/lang/Object;']);
    });
    return nativeMap.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JList.';
  }
}
