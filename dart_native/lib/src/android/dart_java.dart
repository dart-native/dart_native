export 'runtime/jobject.dart';
export 'runtime/call_back.dart';

import 'common/library.dart';

class DartJava {
  /// set so path
  static void loadLibrary(String soPath) {
    if (soPath != null && soPath.isNotEmpty) {
      Library.setLibPath(soPath);
    }
  }
}
