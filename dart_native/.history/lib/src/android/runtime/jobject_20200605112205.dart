import 'dart:ffi';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/common/pointer_encoding.dart';
import 'package:ffi/ffi.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'dart:typed_data';
import 'JObjectPool.dart';
import 'class.dart';

class JObject extends Class{
  Pointer _ptr;

  //init target class
  JObject(String className) : super(className) {
    _ptr = nativeCreateClass(super.classUtf8());
    JObjectPool.sInstance.retain(this);
  }

  dynamic invoke(String methodName, List args) {
    Pointer<Int32> pointers = allocate<Int32>(count: 1);
    pointers.value = 4;


    Pointer<Void> paramPointer = generateParamBuffer(pointers);
    Pointer<Int8> temp = paramPointer.cast();
    Int8List list = temp.asTypedList(2);
    list[1] = "w".codeUnitAt(0);
    print("west flutter ${String.fromCharCode(list[1])}");


    Pointer<Pointer<Void>> ppointers = allocate<Pointer<Void>>(count:  1);
    invokeJavaMethod(Utf8.toUtf8(""), Utf8.toUtf8(""), ppointers);

    releaseParamBuffer();
  }

  Int8List encodeArgs(List args){
    args.forEach((param) {
      
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
