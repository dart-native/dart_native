import 'dart:ffi';

import 'package:dart_objc/src/common/channel_dispatch.dart';
import 'package:dart_objc/src/common/library.dart';
import 'package:dart_objc/src/common/native_types.dart';
import 'package:dart_objc/src/common/pointer_encoding.dart';
import 'package:dart_objc/src/runtime/id.dart';
import 'package:ffi/ffi.dart';

typedef BlockCreateC = Pointer<Void> Function(Pointer<Utf8> typeEncodings);
typedef BlockCreateD = Pointer<Void> Function(Pointer<Utf8> typeEncodings);

final BlockCreateD blockCreate =
    nativeRuntimeLib.lookupFunction<BlockCreateC, BlockCreateD>('block_create');

Map<int, Function> _blockForAddress = {};

class Block extends id {
  Function _function;

  factory Block(Function function) {
    String typeString = _typeStringForFunction(function);
    Pointer<Utf8> typeStringPtr = Utf8.toUtf8(typeString);
    Pointer<Void> blockPtr = blockCreate(typeStringPtr);
    typeStringPtr.free();
    Block result = Block._internal(blockPtr);
    _blockForAddress[blockPtr.address] = function;
    result._function = function;
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
  Function function = _blockForAddress[blockAddr];
  Pointer<Pointer<Void>> argsPtrPtr = Pointer.fromAddress(argsAddr);
  List args = [];
  for (var i = 0; i < argCount; i++) {
    // TODO: get block args encoding.
    // loadValueFromPointer(argsPtrPtr.elementAt(i).load(), encoding);
    
  }
  dynamic result = Function.apply(function, args);
  _blockForAddress.remove(blockAddr);
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
