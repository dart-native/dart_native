import 'package:dart_native/dart_native.dart';
import 'package:dart_native_example/android/runtimestub.dart';

testAndroid(RuntimeStub stub) {
  double resultDouble = stub.getDouble();
  print('getDouble result:$resultDouble');

  String resultChar = stub.getChar();
  print('getChar result:$resultChar');

  int resultInt = stub.getInt();
  print('getInt result:$resultInt');

  bool resultBool = stub.getBool();
  print('getBool result:$resultBool');

  double resultFloat = stub.getFloat();
  print('getFloat result:$resultFloat');
//
//  int resultByte = stub.getByte();
//  print('getChar result:$resultByte');
//
//  int resultShort = stub.getShort();
//  print('getChar result:$resultShort');
}
