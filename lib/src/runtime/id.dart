import 'dart:ffi';

import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/nsobject_protocol.dart';
import 'package:dart_objc/src/runtime/selector.dart';

class id with NSObjectProtocol {
  Class get isa {
    Pointer<Void> isaPtr = object_getClass(_ptr);
    return Class.fromPointer(isaPtr);
  }

  Pointer<Void> _ptr = nullptr;
  Pointer<Void> get pointer {
    if (retainCount == 0) {
      _ptr = nullptr;
    }
    return _ptr;
  }

  int retainCount = 1;

  String get address => '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';

  id(this._ptr);

  factory id.fromPointer(Pointer<Void> ptr) {
    if (object_isClass(ptr) != 0) {
      return Class.fromPointer(ptr);
    } else {
      return NSObject.fromPointer(ptr);
    }
  }
  /// Release NSObject instance.
  /// Subclass can override this method and call release on its dart properties. 
  release() {
    if (this is NSObject && retainCount > 0) {
      retainCount--;
      super.release();
    }
  }

  @override
  String toString() {
    // TODO: description
    return '<${isa.name}: $address>';
  }

  bool operator ==(other) {
    if (other == null) return false;
    return pointer == other.pointer;
  }

  int get hashCode {
    return pointer.hashCode;
  }
}
