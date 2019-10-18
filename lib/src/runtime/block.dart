import 'dart:ffi';

import 'package:dart_objc/src/runtime/id.dart';

class Block extends id {

  Function _function;

  factory Block(Function _function) {
    // TODO: create native block and call dart function
  }
  
  factory Block.fromPointer(Pointer<Void> ptr) {
    return Block._internal(ptr);
  }

  Block._internal(Pointer<Void> ptr) : super(ptr);

  dynamic invoke(List args) {
    Function.apply(_function, args);
  }
}