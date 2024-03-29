import 'dart:io';

import 'package:dart_native_example/android/unit_test.dart';
import 'package:dart_native_example/ios/unit_test.dart';

///
/// dart native unit test.
/// It is a example to use dart_native.
/// Dart use this dispatch to all platform.
///
class DNUnitTest {
  late DNUnitTestBase _unitTest;

  DNUnitTest() {
    /// Dispatch to platform.
    _unitTest = Platform.isAndroid ? DNAndroidUnitTest() : DNAppleUnitTest();
  }

  /// Run all test case.
  Future<void> runAllUnitTests() async {
    return _unitTest.runAllUnitTests();
  }
}

///
/// Base class for all platform.
///
abstract class DNUnitTestBase {
  void runAllUnitTests();
}
