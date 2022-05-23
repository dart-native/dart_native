import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `List` in Android.
const String _jListCls = 'java/util/List';
const String _jArrayListCls = 'java/util/ArrayList';

@native(javaClass: _jListCls)
class JList<E> extends JSubclass<List> {
  JList(List value, {String clsName = _jListCls, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr, {String clsName = _jListCls})
      : super.fromPointer(ptr, clsName) {
    int count = callIntMethodSync('size');
    List temp = List.filled(count, [], growable: false);
    String itemType = '';
    for (var i = 0; i < count; i++) {
      dynamic item = callMethodSync('get', 'Ljava/lang/Object;', args: [i]);
      final convertor = getRegisterPointerConvertor(E.toString());
      if (convertor != null) {
        temp[i] = convertor((item as JObject).pointer);
        continue;
      }
      if (item is String) {
        temp[i] = unBoxingWrapperClass(item, 'java/lang/String');
        continue;
      }
      if (itemType == '') {
        itemType = (item as JObject).className!;
      }
      temp[i] = unBoxingWrapperClass((item as JObject).pointer, itemType);
    }
    raw = temp;
  }
}

@native(javaClass: _jArrayListCls)
class JArrayList<E> extends JList {
  JArrayList(List value) : super(value, clsName: _jArrayListCls);

  JArrayList.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: _jArrayListCls);
}

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == _jListCls) clsName = _jArrayListCls;

    JObject nativeList = JObject(className: clsName);

    for (var i = 0; i < value.length; i++) {
      nativeList.callBoolMethodSync('add',
          args: [boxingWrapperClass(value[i])],
          assignedSignature: ['Ljava/lang/Object;']);
    }
    return nativeList.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JList.';
  }
}
