import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/foundation/nsstring.dart';
import 'package:dart_native/src/ios/runtime/class.dart';
import 'package:dart_native/src/ios/runtime/message.dart';
import 'package:dart_native/src/ios/runtime/selector.dart';
import 'package:dart_native/src/ios/runtime/nsobject.dart';
import 'package:dart_native_gen/dart_native_gen.dart';

@native
class NSError extends NSObject {
  String get domain {
    Pointer<Void> result = perform('domain'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  int get code => perform('code'.toSEL());

  Map get userInfo {
    Pointer<Void> result = perform('userInfo'.toSEL(), decodeRetVal: false);
    return NSDictionary.fromPointer(result).raw;
  }

  String get localizedDescription {
    Pointer<Void> result = perform('localizedDescription'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  String get localizedFailureReason {
    Pointer<Void> result = perform('localizedFailureReason'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  String get localizedRecoverySuggestion {
    Pointer<Void> result = perform('localizedRecoverySuggestion'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }

  List get localizedRecoveryOptions {
    Pointer<Void> result = perform('localizedRecoveryOptions'.toSEL(), decodeRetVal: false);
    return NSArray.fromPointer(result).raw;
  }

  NSObject get recoveryAttempter => perform('recoveryAttempter'.toSEL());

  String get helpAnchor {
    Pointer<Void> result = perform('helpAnchor'.toSEL(), decodeRetVal: false);
    return NSString.fromPointer(result).raw;
  }
  
  NSError.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
  
  NSError(String domain, int code, Map userInfo) : super.fromPointer(_initWithDomainCodeUserInfo(domain, code, userInfo));

  static NSError errorWithDomainCodeUserInfo(String domain, int code, Map userInfo) {
    Pointer<Void> result = Class('NSError').perform('errorWithDomain:code:userInfo:'.toSEL(), args: [domain, code, userInfo], decodeRetVal: false);
    return NSError.fromPointer(result);
  }

  static Pointer<Void> _initWithDomainCodeUserInfo(String domain, int code, Map userInfo) {
    Pointer<Void> target = alloc(Class('NSError'));
    SEL sel = 'initWithDomain:code:userInfo:'.toSEL();
    return msgSend(target, sel, args: [domain, code, userInfo], decodeRetVal: false);
  }
}