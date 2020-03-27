import 'package:flutter/material.dart';
import 'package:dart_native_example/android/android_main.dart';
import 'package:dart_native_example/ios/ios_main.dart';
import 'dart:io';

void main() => runApp(Platform.isAndroid ? AndroidApp() : IOSApp());
