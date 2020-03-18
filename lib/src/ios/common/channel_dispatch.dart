import 'package:flutter/services.dart';

class ChannelDispatch {
  MethodChannel _channel = const MethodChannel('dart_native');
  static final ChannelDispatch _singleton = ChannelDispatch._internal();
  Map<String, Function> _callbacks = {};

  factory ChannelDispatch() {
    return _singleton;
  }

  ChannelDispatch._internal() {
    _channel.setMethodCallHandler(_handler);
  }

  bool registerChannelCallbackIfNot(String method, Function callback) {
    if (_callbacks[method] == null) {
      _callbacks[method] = callback;
      return true;
    }
    return false;
  }

  Future<dynamic> _handler(MethodCall call) async {
    final args = call.arguments;
    Function function = _callbacks[call.method];
    if (function != null) {
      return Function.apply(function, args);
    }
  }
}
