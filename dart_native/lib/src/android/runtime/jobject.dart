import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';
import 'JObjectPool.dart';
import 'class.dart';

const TYPE_DECODE = {
  int: 0,
};

class JObject extends Class {

  int _javaObjectHashCode;

  //init target class
  JObject(String className) : super(className) {
    _javaObjectHashCode = loadValueFromPointer(
        newJavaObject(super.classUtf8()), TypeDecoding.int);
    print("west new java object: ${super
        .classUtf8()}, object hashCode:${_javaObjectHashCode}");
  }

  dynamic invoke(String methodName, List args) {
    encodeToParamBuffer(args);

    //对象引用
    Pointer<Int32> hashCodeParamPointer = allocate<Int32>(count: 1);
    hashCodeParamPointer.value = _javaObjectHashCode;

    Pointer<Void> resultPointer = invokeJavaMethod(
        hashCodeParamPointer, Utf8.toUtf8(methodName));

    releaseParamBuffer();

    return decodeResultBuffer(resultPointer);
  }

  decodeResultBuffer(Pointer<Void> resultPointer) {
    Pointer<Int8> temp = resultPointer.cast();
    Int8List resultBuffer = temp.asTypedList(8);
    
    if (resultBuffer[0] == TYPE_DECODE[int]) {
      return resultBuffer[ 1] | (resultBuffer[ 2] << 8) | (resultBuffer[ 3] <<
          16) | (resultBuffer[ 4] << 24);
    }
    return 0;
  }

  void encodeToParamBuffer(List args) {
    List list = List();
    args.forEach((param) {
      print(param.runtimeType);
      //先放类型
      list.add(TYPE_DECODE[param.runtimeType]);
      //根据类型放数值
      switch (param.runtimeType) {
        case int:
          list.add(param & 0xff);
          list.add((param >> 8) & 0xff);
          list.add((param >> 16) & 0xff);
          list.add((param >> 24) & 0xff);
          break;
      }
    });

    //申请参数编码存放的内存
    int encodeBufferLength = list.length;
    Pointer<Int32> pointers = allocate<Int32>(count: 1);
    pointers.value = encodeBufferLength;
    Pointer<Void> paramPointer = generateParamBuffer(pointers);

    //将申请的内存以Int8List的形式操作
    Pointer<Int8> temp = paramPointer.cast();
    Int8List paramInt8List = temp.asTypedList(encodeBufferLength);

    int curIndex = 0;
    list.forEach((element) {
      paramInt8List[curIndex] = list[curIndex];
      curIndex++;
    });

  }

  release() {
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._javaObjectHashCode == _javaObjectHashCode) {
      return 0;
    }
    return 1;
  }
}
