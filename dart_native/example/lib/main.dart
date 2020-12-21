import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_example/android/android_new_main.dart';
import 'package:dart_native_example/ios/ios_main.dart';
import 'dart:io';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:dart_native/dart_native.dart';

@nativeRoot
void main() {
  DartNative.init();
  runDartNativeExample();
  runApp(Platform.isAndroid ? AndroidNewApp() : IOSApp());
}
