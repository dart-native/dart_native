import 'package:dart_objc/src/runtime/selector.dart';

abstract class NSObjectProtocol {
  dynamic performSelector(Selector selector, [List args]);
}