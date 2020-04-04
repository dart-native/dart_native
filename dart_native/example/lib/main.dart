import 'package:dart_native_example/main.dn.dart';
import 'package:flutter/material.dart';
import 'package:dart_native_example/android/android_new_main.dart';
import 'package:dart_native_example/ios/ios_main.dart';
import 'dart:io';

void main() {
  runDartNativeExample();
  runApp(Platform.isAndroid ? AndroidNewApp() : IOSApp());
}
