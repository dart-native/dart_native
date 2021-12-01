import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Set` in Android.
const String cls_set = 'java/util/Set';
const String cls_hash_set = 'java/util/HashSet';

@nativeJavaClass(cls_set)
class JSet<E> extends JSubclass<Set> {
  JSet(Set value, {String clsName = cls_set, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = Set.of(value);
  }

  JSet.fromPointer(Pointer<Void> ptr,
      {String clsName = cls_set, E Function(Pointer<Void> pointer)? creator})
      : super.fromPointer(ptr, clsName) {
    JObject converter =
        JObject(className: 'com/dartnative/dart_native/ArrayListConverter');
    List list = JList<E>.fromPointer(
            converter.invoke('setToList',
              'Ljava/util/List;',
              args: [JObject.fromPointer(ptr, className: 'java/util/Set')], ),
            creator: creator)
        .raw;
    raw = list.toSet();
  }
}

class JHashSet<E> extends JSet {
  JHashSet(Set value) : super(value, clsName: cls_hash_set);

  JHashSet.fromPointer(Pointer<Void> ptr,
      {E Function(Pointer<Void> pointer)? creator})
      : super.fromPointer(ptr, clsName: cls_hash_set, creator: creator);
}

/// New native 'Set'.
Pointer<Void> _new(dynamic value, String? clsName) {
  if (value is Set) {
    if (clsName == cls_set) clsName = cls_hash_set;

    JObject nativeSet = JObject(className: clsName);

    for (var element in value) {
      nativeSet.invokeBool('add', args: [boxingWrapperClass(element)],
          assignedSignature: ['Ljava/lang/Object;']);
    }
    return nativeSet.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JSet.';
  }
}
