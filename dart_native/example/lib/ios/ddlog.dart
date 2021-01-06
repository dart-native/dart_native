import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class DDLog extends NSObject {
  DDLog([Class isa]) : super(isa ?? Class('DDLog'));
  static int level = 0x11111;
  static void log(int flag, String text, {bool asynchronous = true}) {
    Class('DDLog').perform(
        SEL('log:level:flag:context:file:function:line:tag:format:'),
        args: [asynchronous, level, flag, 0, nullptr, nullptr, 0, nil, text]);
  }
}
