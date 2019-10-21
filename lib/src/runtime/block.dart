import 'dart:ffi';

import 'package:dart_objc/runtime.dart';
import 'package:dart_objc/src/common/channel_dispatch.dart';
import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:dart_objc/src/runtime/message.dart';
import 'package:dart_objc/src/runtime/selector.dart';
import 'package:ffi/ffi.dart';

typedef BlockCreateC = Pointer<Void> Function(Pointer<Utf8> typeEncodings);
typedef BlockCreateD = Pointer<Void> Function(Pointer<Utf8> typeEncodings);

final BlockCreateD blockCreate =
    nativeRuntimeLib.lookupFunction<BlockCreateC, BlockCreateD>('block_create');

Map<int, Block> _blockForAddress = {};

class Block extends id {
  Function function;
  NSObject _blockWrapper;

  factory Block(Function function) {
    String typeString = _typeStringForFunction(function);
    Pointer<Utf8> typeStringPtr = Utf8.toUtf8(typeString);
    NSObject blockWrapper = NSObject.fromPointer(blockCreate(typeStringPtr));
    Block result = Block._internal(blockWrapper.perform(Selector('block')).pointer);
    typeStringPtr.free();
    result._blockWrapper = blockWrapper;
    result.function = function;
    _blockForAddress[result.pointer.address] = result;
    return result;
  }

  factory Block.fromPointer(Pointer<Void> ptr) {
    return Block._internal(ptr);
  }

  Block._internal(Pointer<Void> ptr) : super(ptr) {
    ChannelDispatch().registerChannelCallback('block_invoke', _callback);
  }

  dynamic invoke([List args]) {
    // TODO: invoke native block

  }
}

dynamic _callback(int blockAddr, int argsAddr, int argCount) {
  Block block = _blockForAddress[blockAddr];
  Pointer<Pointer<Void>> argsPtrPtr = Pointer.fromAddress(argsAddr);
  List args = [];
  Pointer pointer = block._blockWrapper.perform(Selector('typeEncodings'));
  Pointer<Pointer<Utf8>> typesPtrPtr = pointer.cast();
  for (var i = 0; i < argCount; i++) {
    // Get block args encoding. First is return type.
    String encoding = Utf8.fromUtf8(typesPtrPtr.elementAt(i + 1).load());
    dynamic arg = loadValueFromPointer(argsPtrPtr.elementAt(i).load(), encoding);
    args.add(arg);
  }
  dynamic result = Function.apply(block.function, args);
  _blockForAddress.remove(blockAddr);
  block.release();
  return result;
}

String _typeStringForFunction(Function function) {
  String typeString = function.runtimeType.toString();
  List<String> argsAndRet = typeString.split(' => ');
  if (argsAndRet.length == 2) {
    String args = argsAndRet.first;
    String ret = argsAndRet.last;
    if (args.length > 2) {
      args = args.substring(1, args.length - 1);
      return '$ret, $args';
    } else {
      return '$ret';
    }
  }
  return '';
}
