import 'package:dart_native/src/darwin/foundation/internal/native_box.dart';

/// These native types are ONLY for describing signatures of Objective-C Block.
typedef BOOL = bool;
typedef NSInteger = int;
typedef NSUInteger = int;
typedef CGFloat = double;

class CString extends NativeBox<String> {
  const CString(String raw) : super(raw);
}

/// Wrapper for Objective-C NS_ENUM
typedef NSEnum = int;

/// Wrapper for Objective-C NS_OPTIONS
typedef NSOptions = int;
