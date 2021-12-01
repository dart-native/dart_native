export 'runtime/jobject.dart';
export 'runtime/extension/jobject_extension.dart';
export 'runtime/extension/jobject_async_extension.dart';
export 'runtime/call_back.dart';
export 'runtime/register.dart';
export 'foundation/collection/jlist.dart';
export 'foundation/collection/jset.dart';
export 'foundation/collection/jarray.dart';
export 'foundation/collection/jmap.dart';
export 'foundation/wrapperclass/integer.dart';
export 'foundation/wrapperclass/boolean.dart';
export 'foundation/wrapperclass/byte.dart';
export 'foundation/wrapperclass/character.dart';
export 'foundation/wrapperclass/double.dart';
export 'foundation/wrapperclass/float.dart';
export 'foundation/wrapperclass/long.dart';
export 'foundation/wrapperclass/short.dart';
export 'foundation/wrapperclass/boxing_unboxing.dart';
export 'foundation/native_type.dart';

import 'common/library.dart';

class DartJava {
  /// set so path
  static void loadLibrary(String? soPath) {
    if (soPath != null && soPath.isNotEmpty) {
      Library.setLibPath(soPath);
    }
  }
}
