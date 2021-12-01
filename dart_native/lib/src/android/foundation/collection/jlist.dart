import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `List` in Android.
const String cls_list = 'java/util/List';
const String cls_array_list = 'java/util/ArrayList';

@nativeJavaClass(cls_list)
class JList<E> extends JSubclass<List> {
  JList(List value, {String clsName = cls_list, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = List.of(value, growable: false);
  }

  JList.fromPointer(Pointer<Void> ptr,
      {String clsName = cls_list,
      E Function(Pointer<Void> pointer)? creator})
      : super.fromPointer(ptr, clsName) {
    int count = invokeInt('size');
    List temp = List.filled(count, [], growable: false);
    String itemType = '';
    for (var i = 0; i < count; i++) {
      dynamic item = invoke('get', 'Ljava/lang/Object;', args: [i]);
      if (creator != null) {
        temp[i] = creator(item);
        continue;
      }
      if (itemType == '') {
        if (item is String) {
          itemType = 'java.lang.String';
        } else {
          itemType = _getItemClass(item);
        }
      }
      temp[i] = unBoxingWrapperClass(item, itemType);
    }
    raw = temp;
  }
}

@nativeJavaClass(cls_array_list)
class JArrayList<E> extends JList {
  JArrayList(List value) : super(value, clsName: cls_array_list);

  JArrayList.fromPointer(Pointer<Void> ptr, {E Function(Pointer<Void> pointer)? creator})
      : super.fromPointer(ptr, clsName: cls_array_list, creator: creator);
}

/// New native 'ArrayList'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is List) {
    ///'List' default implementation 'ArrayList'.
    if (clsName == cls_list) clsName = cls_array_list;

    JObject nativeList = JObject(className: clsName);

    for (var i = 0; i < value.length; i++) {
      nativeList.invokeBool('add', args: [boxingWrapperClass(value[i])],
          assignedSignature: ['Ljava/lang/Object;']);
    }
    return nativeList.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JList.';
  }
}

String _getItemClass(Pointer<Void> itemPtr) {
  JObject templeObject = JObject.fromPointer(itemPtr, className: 'java/lang/Object');
  templeObject = JObject.fromPointer(
      templeObject.invoke('getClass', 'Ljava/lang/Class;'), className: 'java/lang/Class');

  return templeObject.invoke('getName', 'Ljava/lang/String;');
}
