import 'package:dart_native/dart_native.dart';

/// Log using DartNative Interface
final _logInterface = Interface("logInterface");

class LogLevel {
  final int _level;
  static const LogLevel error = LogLevel._internal(0x1);
  static const LogLevel warning = LogLevel._internal(0x11);
  static const LogLevel info = LogLevel._internal(0x111);
  static const LogLevel debug = LogLevel._internal(0x1111);
  static const LogLevel verbose = LogLevel._internal(0x11111);

  const LogLevel._internal(this._level);
}

class Log {
  static e(String message) {
    _log(LogLevel.error, message);
  }

  static w(String message) {
    _log(LogLevel.warning, message);
  }

  static i(String message) {
    _log(LogLevel.info, message);
  }

  static d(String message) {
    _log(LogLevel.debug, message);
  }

  static v(String message) {
    _log(LogLevel.verbose, message);
  }

  static _log(LogLevel level, String message) {
    _logInterface.invoke('log', args: [level._level, message]);
  }
}