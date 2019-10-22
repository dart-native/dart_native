import 'dart:ffi';

import 'package:dart_objc/dart_objc.dart';
import 'package:dart_objc/src/runtime/functions.dart';
import 'package:dart_objc/src/runtime/class.dart';
import 'package:dart_objc/src/runtime/nsobject.dart';
import 'package:dart_objc/src/runtime/nsobject_protocol.dart';

class id with NSObjectProtocol {
  Class get isa {
    Pointer<Void> isaPtr = object_getClass(_ptr);
    return Class.fromPointer(isaPtr);
  }

  Pointer<Void> _ptr = nullptr;
  Pointer<Void> get pointer {
    return _ptr;
  }

  int _retainCount = 1;

  int get retainCount {
    return _retainCount;
  }

  set retainCount(int count) {
    _retainCount = count;
    if (_retainCount == 0) {
      dealloc();
    }
  }

  String get address => '0x${pointer.address.toRadixString(16).padLeft(16, '0')}';

  id(this._ptr);

  factory id.fromPointer(Pointer<Void> ptr) {
    if (object_isClass(ptr) != 0) {
      return Class.fromPointer(ptr);
    } else {
      return NSObject.fromPointer(ptr);
    }
  }

  id retain() {
    if (this is NSObject) {
      retainCount ++;
      return super.retain();
    }
    return this;
  }

  /// Release NSObject instance.
  /// Subclass can override this method and call release on its dart properties. 
  release() {
    if (retainCount > 0) {
      if (this is NSObject) {
        super.release();
      } else if (this is Block) {
        Block_release(this.pointer);
      }
      retainCount--;
    }
  }

  dealloc() {
    _ptr = nullptr;
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
