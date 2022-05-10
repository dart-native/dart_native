import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Map` in Android.
const String _jMapCls = 'java/util/Map';
const String _jHashMapCls = 'java/util/HashMap';

@native(javaClass: _jMapCls)
class JMap<K, V> extends JSubclass<Map> {
  JMap(Map value, {String clsName = _jMapCls, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = Map.of(value);
  }

  JMap.fromPointer(Pointer<Void> ptr, {String clsName = _jMapCls})
      : super.fromPointer(ptr, clsName) {
    Set keySet = JSet<K>.fromPointer(
            (callMethodSync('keySet', 'Ljava/util/Set;') as JObject).pointer)
        .raw;
    Map temp = {};
    String itemType = '';
    for (var key in keySet) {
      dynamic item = callMethodSync('get', 'Ljava/lang/Object;',
          args: [boxingWrapperClass(key)],
          assignedSignature: ['Ljava/lang/Object;']);
      final valueConvertor = getRegisterPointerConvertor(V.toString());
      if (valueConvertor != null) {
        temp[key] = valueConvertor((item as JObject).pointer);
        continue;
      }
      if (item is String) {
        temp[key] = unBoxingWrapperClass(item, 'java/lang/String');
        continue;
      }
      if (itemType == '') {
        itemType = (item as JObject).className!;
      }
      temp[key] = unBoxingWrapperClass((item as JObject).pointer, itemType);
    }
    raw = temp;
  }
}

@native(javaClass: _jHashMapCls)
class JHashMap<K, V> extends JMap {
  JHashMap(Map value) : super(value, clsName: _jHashMapCls);

  JHashMap.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: _jHashMapCls);
}

/// New native 'HashMap'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Map) {
    ///'Map' default implementation 'HashMap'.
    if (clsName == _jMapCls) clsName = _jHashMapCls;

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
