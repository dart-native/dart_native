import 'dart:async';

import 'package:flutter/services.dart';

import 'dart:ffi' as ffi;

class DartJava {
  static const MethodChannel _channel = const MethodChannel('dart_native');

  static Future<int> get platformVersionInt async {
    final int version = await _channel.invokeMethod('getPlatformVersionInt');
    return version;
  }

  static Future<double> get platformVersionDouble async {
    final double version =
        await _channel.invokeMethod('getPlatformVersionDouble');
    return version;
  }

  static Future<ffi.Int8> get platformVersionByte async {
    final ffi.Int8 version =
        await _channel.invokeMethod('getPlatformVersionByte');
    return version;
  }

  static Future<String> get platformVersionString async {
    final String version =
        await _channel.invokeMethod('getPlatformVersionString');
    return version;
  }
}
