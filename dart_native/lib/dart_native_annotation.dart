import 'dart:ffi';

import 'package:dart_native/src/ios/runtime/nsobject.dart';

class NativeClass {
  const NativeClass();
}

typedef dynamic ConvertorFromPointer(Pointer<Void> ptr);

void registerTypeConvertor(String type, ConvertorFromPointer convertor) {
  if (_convertorCache[type] == null) {
    _convertorCache[type] = convertor;
  }
}

dynamic convertFromPointer(String type, dynamic arg) {
  if (arg is NSObject) {
    ConvertorFromPointer convertor = _convertorCache[type];
    if (convertor != null) {
      return convertor(arg.pointer);
    }
  }
  return arg;
}

Map<String, ConvertorFromPointer> _convertorCache = {};