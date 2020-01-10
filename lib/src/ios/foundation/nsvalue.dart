import 'dart:ffi';

import 'package:dart_native/src/ios/runtime.dart';
import 'package:dart_native/src/ios/common/pointer_encoding.dart';
import 'package:dart_native/src/ios/foundation/internal/native_struct.dart';
import 'package:dart_native/src/ios/foundation/struct/cgaffinetransform.dart';
import 'package:dart_native/src/ios/foundation/struct/cgpoint.dart';
import 'package:dart_native/src/ios/foundation/struct/cgrect.dart';
import 'package:dart_native/src/ios/foundation/struct/cgsize.dart';
import 'package:dart_native/src/ios/foundation/struct/cgvector.dart';
import 'package:dart_native/src/ios/foundation/struct/nsdirectionaledgeinsets.dart';
import 'package:dart_native/src/ios/foundation/struct/nsrange.dart';
import 'package:dart_native/src/ios/foundation/struct/uioffset.dart';
import 'package:dart_native/src/ios/runtime/message.dart';
import 'package:dart_native/src/ios/runtime/nssubclass.dart';

class NSValue extends NSSubclass {
  NSValue(dynamic value) : super(value, _new);

  NSValue.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    if (value == null) {
      String encoding = perform(Selector('objCType'));
      String selName = _selNameForNativeValue(encoding);
      value = msgSend(this, Selector(selName), null, false);
    }
  }

  static Pointer<Void> _new(dynamic value) {
    if (value is NativeStruct) {
      return NSValue.valueWithStruct(value).pointer;
    } else if (value is Pointer) {
      return NSValue.valueWithPointer(value).pointer;
    } else {
      throw 'Unknown type for initializing NSValue.';
    }
  }

  String _selNameForNativeValue(String encoding) {
    if (encoding.startsWith('{')) {
      // Structs
      String structName = structNameForEncoding(encoding);
      return '${structName}Value';
    } else if (encoding.length == 1 &&
        encodingToNativeType.containsKey(encoding)) {
      return '${encodingToNativeType[encoding]}Value';
    } else {
      throw 'Invalid encoding type for NSValue: $encoding';
    }
  }

  static NSValue valueWithPointer(Pointer value) {
    NSObject result =
        type(of: NSValue).perform(Selector('valueWithPointer:'), args: [value]);
    return NSValue.fromPointer(result.pointer);
  }

  static NSValue valueWithStruct<T extends NativeStruct>(T struct) {
    String selName = 'valueWith${struct.runtimeType.toString()}:';
    NSObject result =
        type(of: NSValue).perform(Selector(selName), args: [struct]);
    NSValue value = NSValue.fromPointer(result.pointer);
    value.value = struct;
    return value;
  }
}

extension NSValueUIGeometry on NSValue {
  static NSValue valueWithCGPoint(CGPoint point) {
    return NSValue.valueWithStruct(point);
  }

  CGPoint get CGPointValue => perform(Selector('CGPointValue'));

  static NSValue valueWithCGVector(CGVector vector) {
    return NSValue.valueWithStruct(vector);
  }

  CGVector get CGVectorValue => perform(Selector('CGVectorValue'));

  static NSValue valueWithCGSize(CGSize size) {
    return NSValue.valueWithStruct(size);
  }

  CGSize get CGSizeValue => perform(Selector('CGSizeValue'));

  static NSValue valueWithCGRect(CGRect rect) {
    return NSValue.valueWithStruct(rect);
  }

  CGRect get CGRectValue => perform(Selector('CGRectValue'));

  static NSValue valueWithCGAffineTransform(CGAffineTransform transform) {
    return NSValue.valueWithStruct(transform);
  }

  CGAffineTransform get CGAffineTransformValue =>
      perform(Selector('CGAffineTransformValue'));

  static NSValue valueWithNSDirectionalEdgeInsets(
      NSDirectionalEdgeInsets insets) {
    return NSValue.valueWithStruct(insets);
  }

  NSDirectionalEdgeInsets get NSDirectionalEdgeInsetsValue =>
      perform(Selector('NSDirectionalEdgeInsetsValue'));

  static NSValue valueWithUIOffset(UIOffset insets) {
    return NSValue.valueWithStruct(insets);
  }

  UIOffset get UIOffsetValue => perform(Selector('UIOffsetValue'));
}

extension NSValueRange on NSValue {
  static NSValue valueWithRange(NSRange range) {
    return NSValue.valueWithStruct(range);
  }

  NSRange get rangeValue => perform(Selector('rangeValue'));
}
