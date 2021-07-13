import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:ffi/ffi.dart';

/// Stands for `Set` in Android.
const String CLS_HASH_SET = "java/util/HashSet";

class JSet extends JSubclass<Set> {
  JSet(Set value, {String clsName: CLS_HASH_SET, InitSubclass init: _new})
      : super(value, _new, clsName) {
    value = Set.of(value);
  }

  JSet.fromPointer(Pointer<Void> ptr, {String clsName: CLS_HASH_SET})
      : super.fromPointer(ptr, clsName) {
    JObject converter =
        JObject("com/dartnative/dart_native/ArrayListConverter");
    List list = JList.fromPointer(converter.invoke("setToList",
            [JObject("java/util/HashSet", pointer: ptr)], "Ljava/util/List;"))
        .raw;
    raw = list.toSet();
  }
}

Pointer<Utf8> _argSignature = Utf8.toUtf8("Ljava/lang/Object;");

/// New native 'Set'.
Pointer<Void> _new(dynamic value, String clsName) {
  if (value is Set) {
    JObject nativeSet = JObject(clsName);
    if (value == null) {
      return nativeSet.pointer;
    }

    for (var element in value) {
      nativeSet.invoke("add", [boxingWrapperClass(element)], "Z",
          argsSignature: [_argSignature]);
    }
    return nativeSet.pointer;
  } else {
    throw 'Invalid param when initializing JSet.';
  }
}
