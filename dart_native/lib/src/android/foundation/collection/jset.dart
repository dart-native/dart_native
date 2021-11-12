import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Set` in Android.
const String cls_set = "java/util/Set";
const String cls_hash_set = "java/util/HashSet";

class JSet extends JSubclass<Set> {
  JSet(Set value, {String clsName: cls_set, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = Set.of(value);
  }

  JSet.fromPointer(Pointer<Void> ptr, {String clsName: cls_set})
      : super.fromPointer(ptr, clsName) {
    JObject converter =
        JObject("com/dartnative/dart_native/ArrayListConverter");
    List list = JList.fromPointer(converter.invoke("setToList",
            [JObject("java/util/Set", pointer: ptr)], "Ljava/util/List;"))
        .raw;
    raw = list.toSet();
  }
}

class JHashSet extends JSet {
  JHashSet(Set value) : super(value, clsName: cls_hash_set);

  JHashSet.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: cls_hash_set);
}

/// New native 'Set'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Set) {
    if (clsName == cls_set) clsName = cls_hash_set;

    JObject nativeSet = JObject(clsName);

    Pointer<Utf8> argSignature = "Ljava/lang/Object;".toNativeUtf8();
    for (var element in value) {
      nativeSet.invoke("add", [boxingWrapperClass(element)], "Z",
          argsSignature: [argSignature]);
    }
    calloc.free(argSignature);
    return nativeSet.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JSet.';
  }
}
