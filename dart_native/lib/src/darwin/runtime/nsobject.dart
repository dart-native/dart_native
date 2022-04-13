import 'dart:ffi';

import 'package:dart_native/src/darwin/runtime/class.dart';
import 'package:dart_native/src/darwin/runtime/id.dart';
import 'package:dart_native/src/darwin/runtime/internal/nsobject_lifecycle.dart';
import 'package:dart_native/src/darwin/runtime/message.dart';
import 'package:dart_native/src/darwin/runtime/selector.dart';
import 'package:dart_native/src/darwin/runtime/type_convertor.dart';

final id nil = id(nullptr);

typedef Finalizer = void Function();

/// Stands for `NSObject` in iOS and macOS.
///
/// The root class of most Objective-C class hierarchies, from which subclasses inherit a basic interface to the runtime system and the ability to behave as Objective-C objects.
class NSObject extends id {
  Finalizer? _finalizer;
  Finalizer? get finalizer => _finalizer;
  set finalizer(Finalizer? f) {
    removeFinalizerForObject(this);
    _finalizer = f;
    addFinalizerForObject(this);
  }

  NSObject([Class? isa]) : super(_new(isa)) {
    bindLifecycleForObject(this);
  }

  /// Before calling [fromPointer], MAKE SURE the [ptr] for object exists.
  /// If [ptr] was already freed, you would get a crash!
  NSObject.fromPointer(Pointer<Void> ptr) : super(ptr) {
    bindLifecycleForObject(this);
  }

  NSObject init() {
    return performSync(SEL('init'));
  }

  NSObject copy() {
    NSObject result = performSync(SEL('copy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  NSObject mutableCopy() {
    NSObject result = performSync(SEL('mutableCopy'));
    return NSObject.fromPointer(result.autorelease().pointer);
  }

  NSObject autorelease() {
    return performSync(SEL('autorelease'));
  }

  static Pointer<Void> _new(Class? isa) {
    isa ??= Class('NSObject');
    Pointer<Void> resultPtr = isa.performSync(SEL('new'), decodeRetVal: false);
    return msgSendSync(resultPtr, SEL('autorelease'), decodeRetVal: false);
  }
}

Pointer<Void> alloc(Class? isa) {
  isa ??= Class('NSObject');
  Pointer<Void> resultPtr = isa.performSync(SEL('alloc'), decodeRetVal: false);
  return msgSendSync(resultPtr, SEL('autorelease'), decodeRetVal: false);
}

/// Convert [arg] to its custom type, which is annotated with `@native()`.
dynamic objcInstanceFromPointer(Pointer<Void> arg, String? type) {
  if (arg == nullptr) {
    return arg;
  }
  // delete '?' for null-safety
  if (type != null) {
    if (type.endsWith('?')) {
      type = type.substring(0, type.length - 1);
    }
    // check if type is collection, ignore the type of its elements.
    for (String keyword in ['List', 'Map', 'Set']) {
      if (type?.startsWith(keyword) ?? false) {
        type = keyword;
        break;
      }
    }
  } else {
    /// Retrive class name from native.
    var object = NSObject.fromPointer(arg);
    type = object.isa?.name;
  }
  // Create instance of type using converter functions.
  if (type != null) {
    ConvertorFromPointer? convertor = convertorForType(type);
    if (convertor != null) {
      return convertor(arg);
    }
  }
  return NSObject.fromPointer(arg);
}
