export 'runtime/jobject.dart';
export 'runtime/call_back.dart';
export 'foundation/collection/jlist.dart';
export 'foundation/wrappertype/integer.dart';
export 'foundation/wrappertype/boolean.dart';
export 'foundation/wrappertype/byte.dart';
export 'foundation/wrappertype/character.dart';
export 'foundation/wrappertype/double.dart';
export 'foundation/wrappertype/float.dart';
export 'foundation/wrappertype/long.dart';
export 'foundation/wrappertype/short.dart';

import 'common/library.dart';

class DartJava {
  /// set so path
  static void loadLibrary(String soPath) {
    if (soPath != null && soPath.isNotEmpty) {
      Library.setLibPath(soPath);
    }
  }
}
