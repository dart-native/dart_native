import 'dart:ffi';

import 'package:dart_native/src/ios/common/library.dart';

// ignore: non_constant_identifier_names
final int Function() _LP64 =
    nativeDylib.lookup<NativeFunction<Int8 Function()>>('LP64').asFunction();

// ignore: non_constant_identifier_names
final int Function() _NS_BUILD_32_LIKE_64 = nativeDylib
    .lookup<NativeFunction<Int8 Function()>>('NS_BUILD_32_LIKE_64')
    .asFunction();

// ignore: non_constant_identifier_names
bool LP64 = _LP64() != 0;
// ignore: non_constant_identifier_names
bool NS_BUILD_32_LIKE_64 = _NS_BUILD_32_LIKE_64() != 0;
