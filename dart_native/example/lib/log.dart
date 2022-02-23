import 'package:dart_native/dart_native.dart';

/// Log using DartNative Interface
final _logInterface = Interface("logInterface");

_log(LogLevel level, String message) {
  _logInterface.invoke('log', args: [level.raw, message]);
}

class LogLevel {
  final int raw;
  static const LogLevel error = LogLevel._internal(0x1);
  static const LogLevel warning = LogLevel._internal(0x3);
  static const LogLevel info = LogLevel._internal(0x7);
  static const LogLevel debug = LogLevel._internal(0xF);
  static const LogLevel verbose = LogLevel._internal(0x1F);

  const LogLevel._internal(this.raw);
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

  static setLevel(LogLevel level) {
    _logInterface.invoke('setLevel', args: [level.raw]);
  }
}
