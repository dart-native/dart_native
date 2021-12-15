// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DartNativeJavaGenerator
// **************************************************************************

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/foundation/collection/jset.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/integer.dart';
import 'package:dart_native/src/android/foundation/collection/jarray.dart';
import 'package:dart_native/src/android/foundation/collection/jlist.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/float.dart';
import 'package:dart_native/src/android/foundation/collection/jmap.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/long.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/short.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/byte.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/character.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/double.dart';
import 'package:dart_native/src/android/foundation/wrapperclass/boolean.dart';

bool _hadRanDartNative = false;
bool get hadRanDartNative => _hadRanDartNative;

void runJavaDartNative() {
  if (_hadRanDartNative) {
    return;
  }
  _hadRanDartNative = true;

  registerJavaTypeConvertor('JSet', 'java/util/Set', (ptr) {
    return JSet.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JHashSet', 'java/util/HashSet', (ptr) {
    return JHashSet.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JInteger', 'java/lang/Integer', (ptr) {
    return JInteger.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JArray', 'java/lang/Object', (ptr) {
    return JArray.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JList', 'java/util/List', (ptr) {
    return JList.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JArrayList', 'java/util/ArrayList', (ptr) {
    return JArrayList.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JFloat', 'java/lang/Float', (ptr) {
    return JFloat.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JMap', 'java/util/Map', (ptr) {
    return JMap.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JHashMap', 'java/util/HashMap', (ptr) {
    return JHashMap.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JLong', 'java/lang/Long', (ptr) {
    return JLong.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JShort', 'java/lang/Short', (ptr) {
    return JShort.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JByte', 'java/lang/Byte', (ptr) {
    return JByte.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JCharacter', 'java/lang/Character', (ptr) {
    return JCharacter.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JDouble', 'java/lang/Double', (ptr) {
    return JDouble.fromPointer(ptr);
  });

  registerJavaTypeConvertor('JBoolean', 'java/lang/Boolean', (ptr) {
    return JBoolean.fromPointer(ptr);
  });
}
