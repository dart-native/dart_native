import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';

/// Stands for `Set` in Android.
const String cls_set = "java/util/Set";
const String cls_hash_set = "java/util/HashSet";

class JSet<E> extends JSubclass<Set> {
  JSet(Set value, {String clsName: cls_set, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = Set.of(value);
  }

  JSet.fromPointer(Pointer<Void> ptr,
      {String clsName: cls_set, E Function(Pointer pointer)? creator})
      : super.fromPointer(ptr, clsName) {
    JObject converter =
        JObject("com/dartnative/dart_native/ArrayListConverter");
    List list = JList<E>.fromPointer(
            converter.invoke("setToList",
                [JObject("java/util/Set", pointer: ptr)], "Ljava/util/List;"),
            creator: creator)
        .raw;
    raw = list.toSet();
  }
}

class JHashSet<E> extends JSet {
  JHashSet(Set value) : super(value, clsName: cls_hash_set);

  JHashSet.fromPointer(Pointer<Void> ptr,
      {E Function(Pointer pointer)? creator})
      : super.fromPointer(ptr, clsName: cls_hash_set, creator: creator);
}

/// New native 'Set'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Set) {
    if (clsName == cls_set) clsName = cls_hash_set;

    JObject nativeSet = JObject(clsName);

    for (var element in value) {
      nativeSet.invoke("add", [boxingWrapperClass(element)], "Z",
          assignedSignature: ["Ljava/lang/Object;"]);
    }
    return nativeSet.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JSet.';
  }
}
