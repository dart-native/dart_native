import 'dart:ffi';

import 'package:dart_objc/src/common/library.dart';

final int Function() _LP64 =
    nativeLib.lookup<NativeFunction<Int8 Function()>>('LP64').asFunction();

final int Function() _NS_BUILD_32_LIKE_64 = nativeLib
    .lookup<NativeFunction<Int8 Function()>>('NS_BUILD_32_LIKE_64')
    .asFunction();

bool LP64 = _LP64() != 0;
bool NS_BUILD_32_LIKE_64 = _NS_BUILD_32_LIKE_64() != 0;
