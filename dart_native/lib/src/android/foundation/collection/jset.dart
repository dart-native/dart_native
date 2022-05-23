import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/runtime/jsubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `Set` in Android.
const String _jSetCls = 'java/util/Set';
const String _jHashSetCls = 'java/util/HashSet';

@native(javaClass: _jSetCls)
class JSet<E> extends JSubclass<Set> {
  JSet(Set value, {String clsName = _jSetCls, InitSubclass init = _new})
      : super(value, _new, clsName) {
    value = Set.of(value);
  }

  JSet.fromPointer(Pointer<Void> ptr, {String clsName = _jSetCls})
      : super.fromPointer(ptr, clsName) {
    JObject converter =
        JObject(className: 'com/dartnative/dart_native/ArrayListConverter');
    List list = JList<E>.fromPointer((converter.callMethodSync(
                'setToList', 'Ljava/util/List;', args: [
      JObject.fromPointer(ptr, className: 'java/util/Set')
    ]) as JObject)
            .pointer)
        .raw;
    raw = list.toSet();
  }
}

@native(javaClass: _jHashSetCls)
class JHashSet<E> extends JSet {
  JHashSet(Set value) : super(value, clsName: _jHashSetCls);

  JHashSet.fromPointer(Pointer<Void> ptr)
      : super.fromPointer(ptr, clsName: _jHashSetCls);
}

/// New native 'Set'.
Pointer<Void> _new(dynamic value, String? clsName) {
  if (value is Set) {
    if (clsName == _jSetCls) clsName = _jHashSetCls;

    JObject nativeSet = JObject(className: clsName);

    for (var element in value) {
      nativeSet.callBoolMethodSync('add',
          args: [boxingWrapperClass(element)],
          assignedSignature: ['Ljava/lang/Object;']);
    }
    return nativeSet.pointer.cast<Void>();
  } else {
    throw 'Invalid param when initializing JSet.';
  }
}
