import 'dart:ffi';

import 'package:dart_native/src/ios/foundation/struct/catransform3d.dart';
import 'package:dart_native/src/ios/foundation/struct/uiedgeinsets.dart';
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
import 'package:dart_native/src/ios/runtime/internal/nssubclass.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSValue` in iOS and macOS.
@native()
class NSValue extends NSSubclass {
  NSValue(dynamic value) : super(value, _new);

  NSValue.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr) {
    // TODO: Do these things on native.
    String encoding = perform(SEL('objCType'));
    String? selName = _selNameForNativeValue(encoding);
    if (selName == null) {
      throw 'Invalid encoding type for NSValue: $encoding';
    } else {
      raw = msgSend(pointer, SEL(selName));
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

  String? _selNameForNativeValue(String encoding) {
    if (encoding.startsWith('{')) {
      // Structs
      String? structName = structNameForEncoding(encoding);
      if (structName == null) {
        return null;
      }
      const specialStructs = {
        'NSPoint': 'point',
        'NSSize': 'size',
        'NSRect': 'rect',
        'NSRange': 'range',
        'NSEdgeInsets': 'edgeInsets'
      };
      String selPrefix = specialStructs[structName] ?? structName;
      return '${selPrefix}Value';
    } else if (encoding.length == 1 &&
        _encodingToNativeValueName.containsKey(encoding)) {
      return '${_encodingToNativeValueName[encoding]}Value';
    }
    return null;
  }

  static NSValue valueWithPointer(Pointer value) {
    NSObject result =
        type(of: NSValue).perform(SEL('valueWithPointer:'), args: [value]);
    return NSValue.fromPointer(result.pointer);
  }

  /// Stands for `-[NSValue valueWith{StructName}]` in iOS and macOS.
  /// `StructName` is [struct].runtimeType.toString() by default. You can also pass in an alias:
  /// See the implementation of [valueWithRange] in [NSValueRangeExtensions].
  static NSValue valueWithStruct<T extends NativeStruct>(T struct,
      {String? structAlias}) {
    String selName = 'valueWith${structAlias ?? struct.aliasForNSValue}:';
    NSObject result = type(of: NSValue).perform(SEL(selName), args: [struct]);
    NSValue value = NSValue.fromPointer(result.pointer);
    value.raw = struct;
    return value;
  }
}

Map<String, String> _encodingToNativeValueName = {
  'c': 'char',
  'C': 'unsignedChar',
  's': 'short',
  'S': 'unsignedShort',
  'i': 'int',
  'I': 'unsignedInt',
  'l': 'long',
  'L': 'unsignedLong',
  'q': 'longLong',
  'Q': 'unsignedLongLong',
  'f': 'float',
  'd': 'double',
  'B': 'bool',
};

extension NSValueUIGeometryExtensions on NSValue {
  static NSValue valueWithCGPoint(CGPoint point) {
    return NSValue.valueWithStruct(point);
  }

  // ignore: non_constant_identifier_names
  CGPoint get CGPointValue => perform(SEL('CGPointValue'));

  static NSValue valueWithCGVector(CGVector vector) {
    return NSValue.valueWithStruct(vector);
  }

  // ignore: non_constant_identifier_names
  CGVector get CGVectorValue => perform(SEL('CGVectorValue'));

  static NSValue valueWithCGSize(CGSize size) {
    return NSValue.valueWithStruct(size);
  }

  // ignore: non_constant_identifier_names
  CGSize get CGSizeValue => perform(SEL('CGSizeValue'));

  static NSValue valueWithCGRect(CGRect rect) {
    return NSValue.valueWithStruct(rect);
  }

  // ignore: non_constant_identifier_names
  CGRect get CGRectValue => perform(SEL('CGRectValue'));

  static NSValue valueWithCGAffineTransform(CGAffineTransform transform) {
    return NSValue.valueWithStruct(transform);
  }

  // ignore: non_constant_identifier_names
  CGAffineTransform get CGAffineTransformValue =>
      perform(SEL('CGAffineTransformValue'));

  static NSValue valueWithUIEdgeInsets(UIEdgeInsets insets) {
    return NSValue.valueWithStruct(insets);
  }

  // ignore: non_constant_identifier_names
  UIEdgeInsets get UIEdgeInsetsValue => perform(SEL('UIEdgeInsetsValue'));

  static NSValue valueWithDirectionalEdgeInsets(
      NSDirectionalEdgeInsets insets) {
    return NSValue.valueWithStruct(insets);
  }

  NSDirectionalEdgeInsets get directionalEdgeInsetsValue =>
      perform(SEL('directionalEdgeInsetsValue'));

  static NSValue valueWithUIOffset(UIOffset insets) {
    return NSValue.valueWithStruct(insets);
  }

  // ignore: non_constant_identifier_names
  UIOffset get UIOffsetValue => perform(SEL('UIOffsetValue'));
}

extension NSValueGeometryExtensions on NSValue {
  static NSValue valueWithPoint(NSPoint point) {
    return NSValue.valueWithStruct(point);
  }

  // ignore: non_constant_identifier_names
  NSPoint get pointValue => perform(SEL('pointValue'));

  static NSValue valueWithSize(NSSize size) {
    return NSValue.valueWithStruct(size);
  }

  // ignore: non_constant_identifier_names
  NSSize get sizeValue => perform(SEL('sizeValue'));

  static NSValue valueWithRect(NSRect rect) {
    return NSValue.valueWithStruct(rect);
  }

  // ignore: non_constant_identifier_names
  NSRect get rectValue => perform(SEL('rectValue'));

  static NSValue valueWithEdgeInsets(NSEdgeInsets insets) {
    return NSValue.valueWithStruct(insets);
  }

  // ignore: non_constant_identifier_names
  NSEdgeInsets get edgeInsetsValue => perform(SEL('edgeInsetsValue'));
}

extension NSValueRangeExtensions on NSValue {
  static NSValue valueWithRange(NSRange range) {
    return NSValue.valueWithStruct(range);
  }

  NSRange get rangeValue => perform(SEL('rangeValue'));
}

extension CATransform3DAdditions on NSValue {
  static NSValue valueWithCATransform3D(CATransform3D transform) {
    return NSValue.valueWithStruct(transform);
  }

  // ignore: non_constant_identifier_names
  CATransform3D get CATransform3DValue => perform(SEL('CATransform3DValue'));
}
