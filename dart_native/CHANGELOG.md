## 0.7.11

* [Fix] A dangling pointer on Android.
* [Fix] DetachCurrentThread crash on Android.
* [Feature] Collections support automatic type conversions on Android.

## 0.7.10

* [Fix] A dangling pointer on Android.
* [Fix] DetachCurrentThread crash on Android.
* [Feature] Collections support automatic type conversions on Android.

## 0.7.9

* Bump to ffi >=1.1.2
* [Fix] Thread Performance Checker issue
* [Fix] Flutter debug warning

## 0.7.8

* [Fix] Build error on Xcode 12.
* [Fix] The result for interface doesn't match it's type bool.

## 0.7.7

* [Fix] https://github.com/dart-native/dart_native/issues/108

## 0.7.6

* [Fix] https://github.com/dart-native/dart_native/issues/107

## 0.7.5

* [Fix] Crash on iOS.
* [Fix] https://github.com/dart-native/dart_native/issues/103

## 0.7.4

* [Fix] Errors and warnings.
* [Fix] Dart exceptions on Android.

## 0.7.3

* [Fix] Garbage characters on Android.

## 0.7.2

* [Fix] Support Promise on Android.

## 0.7.1

* [Fix] Leaks on iOS.

## 0.7.0

* [Feature] Support DartNative Interface.
* [Feature] Support Finalizer.

## 0.6.8

* [Fix] Leaks on iOS.

## 0.6.7

* [Fix] Deadlocks on iOS.

## 0.6.6

* [Fix] Dependency verison compatible.

## 0.6.5

* [Fix] Fix utf16 issue on iOS.

## 0.6.4

* [Fix] Failed to load dynamic library on Android.

## 0.6.3

* [Fix] Split podspec files for iOS and macOS.

## 0.6.2

* [Fix] Exceptions on macOS.

## 0.6.1

* [Fix] Dart version compatibility.

## 0.6.0

* [Feature] Support macOS.
* [Feature] Optimize the way you initialize the path to the so file on Android.

## 0.5.0

* [Feature] Add annotation for Android: `@native(javaClass:)`
* [Feature] Update annotation for iOS: `@native` -> `@native()`
* [Fix] Crash on Android simulator.

## 0.4.0

* [Feature] Adapted to Flutter 2.2 and nullsafety.
* [Feature] Add example for Swift 5.
* [Feature] Enhanced type conversion.
* [Feature] Refactoring the interface and implementation.

## 0.3.23

* [Fix] Some issues on 32-bit Android.

## 0.3.22

* [Fix] Callbacks from multi-isolates on iOS.

## 0.3.21

* [Fix] Some crashes on Android.

## 0.3.20

* [Feature] Support 64 bit on Android.

## 0.3.19

* [Fix] Some crashes on Android.

## 0.3.18

* [Feature] Support multi-isolates.

## 0.3.17

* [Fix] Type encoding issue on iOS.

## 0.3.16

* [Fix] JNI environment issue on Android.

## 0.3.15

* [Fix] Performance issue on iOS.

## 0.3.14

* [Feature] Support `await/async` for methods on iOS.

## 0.3.13

* [Fix] Memory leaks on Android.

## 0.3.12

* [Feature] Support List/Array for Android.

## 0.3.11

* [Fix] Skip BOM for Utf-16 on iOS. Sad!

## 0.3.10

* [Fix] Skip BOM for Utf-16 on iOS.

## 0.3.9

* [Fix] iOS framework compatibility.

## 0.3.8

* [Feature] Android so file path.

## 0.3.7

* [Feature] Android callback result.
 
## 0.3.6

* [Fix] Issue: https://github.com/dart-native/dart_native/issues/24

## 0.3.5

* [Feature] Object lifecycle management for Android.
* [Feature] Callback from Android to Flutter.

## 0.3.4

* Performance optimization for iOS `NSString`.
* Fix bugs. 

## 0.3.3

* Fix bug for `NSDictionary`.

## 0.3.2

* Expose `id.dart` and `message.dart` in iOS.

## 0.3.1

* Fix issue for pub.dev.

## 0.3.0

* Automatic lifecycle management for iOS platform. 
* Fix bugs.

## 0.2.0

* Performance optimization and more feature for Android.
* Fix bugs.

## 0.1.18

* Support annotation for API availability.

## 0.1.17

* Support `NSError`
* Fix bugs.

## 0.1.16

### Android
* Support string type.
### iOS
* Support `NSObject **` type for argument type.
* Support mutable collection types.
* Support `NS_ENUM` and `NS_OPTIONS`

## 0.1.15

* Fix CI.
* Update readme.

## 0.1.14

* Support Android basic types.
* Support automatic type conversions for callback(block/delegate/notification).

## 0.1.13

* Fix iOS memory leak.
* Support iOS struct dealloc callback.
* Add sample code for Android.

## 0.1.12

* Fix issue for callback.

## 0.1.11

* Support stret for method callback.

## 0.1.10

* Fix issue for "dart_native" channel.
* Support stret for block.

## 0.1.9

* Change plugin name to "dart_native".

## 0.1.8

* Dart function can be observer for `NSNotification`.
* Fix issue for automatic transfer of `NSRange`.

## 0.1.7

* Update dependancy.

## 0.1.6

* Update readme.
* Delete useless code.

## 0.1.5

* Delete code for banckmark.

## 0.1.4

* Performance optimization.
* Bug fix.

## 0.1.3

* Support more structs: `CGPoint`, `CGVector`, `CGSize`, `CGRect`, `CGAffineTransform`, `UIEdgeInsets`, `NSDirectionalEdgeInsets`, `UIOffset`.
* Support collections: `NSArray`, `NSDictionary`, `NSSet`.
* Support box/unbox: `NSValue`, `NSNumber`.

## 0.1.2

* Perform method on main/global queue.

## 0.1.1

* Fix issue for block and delegate callback when returning an object.

## 0.1.0

* Fix CString and Struct memory issue.

## 0.1.0-dev.1

* Update SDK constraint to 2.6.0-dev.8.2

## 0.0.6

* Convert `bool` Automatically.

## 0.0.5

* Fix memory leak.

## 0.0.4

* Support `NSString`.
* Fix some memory issue.

## 0.0.3

* Support delegate callback.

## 0.0.2

* Format code.

## 0.0.1

* Initial release.

