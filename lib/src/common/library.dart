import 'dart:ffi';

final DynamicLibrary nativeRuntimeLib =
    DynamicLibrary.open('dart_objc.framework/dart_objc');
final DynamicLibrary nativeLib = DynamicLibrary.process();
