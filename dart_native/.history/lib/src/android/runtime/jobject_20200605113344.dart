import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';
import 'JObjectPool.dart';
import 'class.dart';
import 'dart:mirrors';

class JObject extends Class {
  Pointer _ptr;

  //init target class
  JObject(String className) : super(className) {
    _ptr = nativeCreateClass(super.classUtf8());
    JObjectPool.sInstance.retain(this);
  }

  dynamic invoke(String methodName, List args) {
    encodeToParamBuffer(args);
    invokeJavaMethod(Utf8.toUtf8(""), Utf8.toUtf8(""), ppointers);

    releaseParamBuffer();
  }

  void encodeToParamBuffer(List args) {
    //申请参数编码存放的内存
    int encodeBufferLength = 4;
    Pointer<Int32> pointers = allocate<Int32>(count: 1);
    pointers.value = encodeBufferLength;
    Pointer<Void> paramPointer = generateParamBuffer(pointers);

    //将申请的内存以Int8List的形式操作
    Pointer<Int8> temp = paramPointer.cast();
    Int8List list = temp.asTypedList(encodeBufferLength);

    int curIndex = 0;
    args.forEach((param) {
      print(param.runtimeType);
      list[curIndex++] = "w".codeUnitAt(0);
      print("west flutter ${String.fromCharCode(list[1])}");
    });
  }

  release() {
    if (JObjectPool.sInstance.release(this)) {
      nativeReleaseClass(_ptr);
    }
  }

  @override
  int compareTo(other) {
    if (other is JObject && other._ptr == _ptr) {
      return 0;
    }
    return 1;
  }
}
