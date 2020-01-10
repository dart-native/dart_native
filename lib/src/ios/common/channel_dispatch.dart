import 'package:flutter/services.dart';

class ChannelDispatch {
  MethodChannel _channel = const MethodChannel('dart_objc');
  static final ChannelDispatch _singleton = ChannelDispatch._internal();
  Map<String, Function> _callbacks = {};

  factory ChannelDispatch() {
    return _singleton;
  }

  ChannelDispatch._internal() {
    _channel.setMethodCallHandler(_handler);
  }

  registerChannelCallback(String method, Function callback) {
    _callbacks[method] = callback;
  }

  Future<dynamic> _handler(MethodCall call) async {
    final args = call.arguments;
    Function function = _callbacks[call.method];
    if (function != null) {
      return Function.apply(function, args);
    }
  }
}
