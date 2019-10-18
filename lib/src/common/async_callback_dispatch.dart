import 'package:flutter/services.dart';

class AsyncCallbackDispatch {
  static const MethodChannel _channel =
      const MethodChannel('dart_objc');
  
  AsyncCallbackDispatch() {
    _channel.setMethodCallHandler(handler);
  }

  Future<dynamic> handler(MethodCall call) {
    final args = call.arguments;
    return Future.value(1);
  }
}