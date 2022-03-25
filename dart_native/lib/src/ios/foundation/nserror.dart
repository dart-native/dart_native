import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

/// Stands for `NSError` in iOS and macOS.
@native()
class NSError extends NSObject {
  String get domain {
    Pointer<Void> result = performSync('domain'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  int get code => performSync('code'.toSEL());

  Map get userInfo {
    Pointer<Void> result = performSync('userInfo'.toSEL(), decodeRetVal: false);
    return NSDictionary.fromPointer(result).raw;
  }

  String get localizedDescription {
    Pointer<Void> result =
        performSync('localizedDescription'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  String get localizedFailureReason {
    Pointer<Void> result =
        performSync('localizedFailureReason'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  String get localizedRecoverySuggestion {
    Pointer<Void> result =
        performSync('localizedRecoverySuggestion'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  List get localizedRecoveryOptions {
    Pointer<Void> result =
        performSync('localizedRecoveryOptions'.toSEL(), decodeRetVal: false);
    return NSArray.fromPointer(result).raw;
  }

  NSObject get recoveryAttempter => performSync('recoveryAttempter'.toSEL());

  String get helpAnchor {
    Pointer<Void> result = performSync('helpAnchor'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  NSError.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  NSError(String domain, int code, {Map? userInfo})
      : super.fromPointer(_initWithDomainCodeUserInfo(domain, code, userInfo));

  static NSError errorWithDomainCodeUserInfo(String domain, int code,
      {Map? userInfo}) {
    Pointer<Void> result = Class('NSError').performSync(
        'errorWithDomain:code:userInfo:'.toSEL(),
        args: [domain, code, userInfo],
        decodeRetVal: false);
    return NSError.fromPointer(result);
  }

  static setUserInfoValueProviderForDomain(
      String errorDomain, Function provider) {
    Class('NSError').performSync(
        'setUserInfoValueProviderForDomain:provider:'.toSEL(),
        args: [errorDomain, provider]);
  }

  static Block userInfoValueProviderForDomain(String errorDomain) {
    return Class('NSError').performSync(
        'userInfoValueProviderForDomain:provider:'.toSEL(),
        args: [errorDomain]);
  }

  static Pointer<Void> _initWithDomainCodeUserInfo(
      String domain, int code, Map? userInfo) {
    Pointer<Void> target = alloc(Class('NSError'));
    SEL sel = 'initWithDomain:code:userInfo:'.toSEL();
    return msgSendSync(target, sel,
        args: [domain, code, userInfo], decodeRetVal: false);
  }
}
