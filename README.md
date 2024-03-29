# DartNative

DartNative operates as a bridge to communicate between Dart and native APIs.

Replaces the low-performing Flutter channel with faster and more concise code.

[![pub package](https://img.shields.io/pub/v/dart_native.svg)](https://pub.dev/packages/dart_native)
[![Build Status](https://app.travis-ci.com/dart-native/dart_native.svg?branch=master)](https://app.travis-ci.com/dart-native/dart_native)
[![Dart CI](https://github.com/dart-native/dart_native/actions/workflows/dart.yml/badge.svg)](https://github.com/dart-native/dart_native/actions/workflows/dart.yml)

## Features

### Dynamic synchronous & asynchronous channeling

DartNative calls *any* native API *dynamically*. It supports both synchronous and asynchronous channeling. 

### Direct call between multi-language interfaces

Serialization of parameters and return values like Flutter Channel is no longer required. DartNative provides direct calls and automatic object marshalling between language interfaces.

### Dart finalizer

Dart finalizer is only supported above Flutter 3(Dart 2.17), but with DartNative it is available in Dart Flutter 2.2.0(Dart 2.13.0) and up.

### Autogenerate succinct bridging code

DartNative supports automatic type conversion so its bridging code is shorter & simpler than the Flutter channel.

The design and vision of this package:

![](images/dartnative.png)

## Requirements

| DartNative Version | Flutter Requirements | Codegen Version |
| --- | --- | --- |
| 0.4.x - 0.7.x | Flutter 2.2.0 (Dart 2.13.0) | 2.x |
| 0.3.x | Flutter 1.20.0 (Dart 2.9.1) | 1.2.x |
| 0.2.x | Flutter 1.12.13 (Dart 2.7) | 1.x |

## Supported Platforms

iOS & macOS & Android

## Usage

### Basic usage: Interface binding

Add ```dart_native``` to dependencies and ```build_runner``` to dev_dependencies. Then you can write code. Here are some examples:

#### Dart calls Native

Dart code:

```dart
final interface = Interface("MyFirstInterface");
// Example for string type.
String helloWorld() {
    return interface.invokeMethodSync('hello', args: ['world']);
}
// Example for num type.
Future<int> sum(int a, int b) {
    return interface.invokeMethod('sum', args: [a, b]);
}
```

Corresponding Objective-C code:

```objectivec
@implementation DNInterfaceDemo

// Register interface name.
InterfaceEntry(MyFirstInterface)

// Register method "hello".
InterfaceMethod(hello, myHello:(NSString *)str) {
    return [NSString stringWithFormat:@"hello %@!", str];
}

// Register method "sum".
InterfaceMethod(sum, addA:(int32_t)a withB:(int32_t)b) {
    return @(a + b);
}

@end
```

Corresponding Java code:

```java

// load libdart_native.so
DartNativePlugin.loadSo();

@InterfaceEntry(name = "MyFirstInterface")
public class InterfaceDemo extends DartNativeInterface {

    @InterfaceMethod(name = "hello")
    public String hello(String str) {
        return "hello " + str;
    }

    @InterfaceMethod(name = "sum")
    public int sum(int a, int b) {
        return a + b;
    }
}
```

NOTE: If your so path is custom, you need pass specific path.
```Java
DartNativePlugin.loadSoWithCustomPath("xxx/libdart_native.so");
```
And before using DartNative in dart, first invoke ```dartNativeInitCustomSoPath()```. It will get path from channel.

#### Native calls Dart

Dart code:

```dart
interface.setMethodCallHandler('totalCost',
        (double unitCost, int count, List list) async {
    return {'totalCost: ${unitCost * count}': list};
});
```

Corresponding Objective-C code:

```objectivec
[self invokeMethod:@"totalCost"
         arguments:@[@0.123456789, @10, @[@"testArray"]]
            result:^(id _Nullable result, NSError * _Nullable error) {
    NSLog(@"%@", result);
}];

```

Corresponding Java code:

```java
invokeMethod("totalCost", new Object[]{0.123456789, 10, Arrays.asList("hello", "world")},
             new DartNativeResult() {
                @Override
                public void onResult(@Nullable Object result) {
                    Map retMap = (Map) result;
                    // do something
                }

                @Override
                public void error(@Nullable String errorMessage) {
                    // do something
                }
              }
);
```

#### Dart finalizer

```dart
final foo = Bar(); // A custom instance.
unitTest.addFinalizer(() { // register a finalizer callback.
  print('The instance of \'foo\' has been destroyed!'); // When `foo` is destroyed by GC, this line of code will be executed.
});
```

#### Data types support

| Dart | Objective-C | Swift | Java |
| --- | --- | --- | --- |
| null | nil | nil | null |
| bool | BOOL | Bool | bool |
| int | NSInteger | Int |int  |
| double | double | Double | double |
| String | NSString | String | String |
| List | NSArray | Array | List, ArrayList |
| Map | NSDictionary | Dictionary | Map, HashMap |
| Set | NSSet | Set | Set, HashSet |
| Function | Block | Closure | Promise |
| Pointer | void * | UnsafeMutableRawPointer | - |
| NativeByte | NSData | Data | DirectByteBuffer |
| NativeObject | NSObject | NSObject | Object |

### Advanced usage: Invoke methods dynamically

- Step 1: Add ```dart_native``` to dependencies and ```build_runner``` to dev_dependencies.

- Step 2: Generate Dart wrapper code with [@dartnative/codegen](https://www.npmjs.com/package/@dartnative/codegen) or write Dart code manually.

- Step 3: Generate code for automatic type conversion using [dart_native_gen](https://pub.dev/packages/dart_native_gen) with the following steps (3.1-3.3):

  + 3.1 Annotate a Dart wrapper class with `@native`.
    ```dart
    @native
    class RuntimeSon extends RuntimeStub {
      RuntimeSon([Class isa]) : super(Class('RuntimeSon'));
      RuntimeSon.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
    }
    ```
  
  + 3.2 Annotate your own entry (such as`main()`) with `@nativeRoot`.

    ```dart
    @nativeRoot
    void main() {
      runApp(App());
    }
    ```

  + 3.3 Run  
    ```bash 
    flutter packages pub run build_runner build --delete-conflicting-outputs 
    ```
    to generate files into your source directory.

    Note: we recommend running `clean` first:

    ```bash
    flutter packages pub run build_runner clean
    ```

- Step 4: Call autogenerated function in `<generated-name>.dn.dart` in 3.3. The function name is determined by `name` in `pubspec.yaml`.

    ```dart
    @nativeRoot
    void main() {
      // Function name is generated by name in pubspec.yaml.
      runDartNativeExample(); 
      runApp(App());
    }
    ```

- Step 5: Then you can write code. Here are some examples:

  + 5.1 iOS:

    Dart code (generated):

    ```dart
    // new Objective-C object.
    RuntimeStub stub = RuntimeStub();

    // Dart function will be converted to Objective-C block.
    stub.fooBlock((NSObject a) {
        print('hello block! ${a.toString()}');
        return 101;
    });

    // support built-in structs.
    CGRect rect = stub.fooCGRect(CGRect(4, 3, 2, 1));
    print(rect);

    ```
    Corresponding Objective-C code:

    ```objc
    typedef int(^BarBlock)(NSObject *a);

    @interface RuntimeStub

    - (CGRect)fooCGRect:(CGRect)rect;
    - (void)fooBlock:(BarBlock)block;

    @end
    ```

    More iOS examples see: [ios_unit_test.dart](/dart_native/example/lib/ios/unit_test.dart)

  + 5.2 Android:

    Dart code (generated):
    ```dart
    // new Java object.
    RuntimeStub stub = RuntimeStub();

    // get java list.
    List list = stub.getList([1, 2, 3, 4]);

    // support interface.
    stub.setDelegateListener(DelegateStub());

    ```
    Corresponding Java code:

    ```java
    public class RuntimeStub {

        public List<Integer> getList(List<Integer> list) {
            List<Integer> returnList = new ArrayList<>();
            returnList.add(1);
            returnList.add(2);
            return returnList;
        }

        public void setDelegateListener(SampleDelegate delegate) {
            delegate.callbackInt(1);
        }
    }
    ```
    More android examples see: [android_unit_test.dart](/dart_native/example/lib/android/unit_test.dart)

NOTE: *If you use dart_native on macOS, you must use `use_frameworks!` in your Podfile.*

## Documentation

### Further reading

- [告别 Flutter Channel，调用 Native API 仅需一行代码！](http://yulingtianxia.com/blog/2020/06/25/Codegen-for-DartNative/)
- [如何实现一行命令自动生成 Flutter 插件](http://yulingtianxia.com/blog/2020/07/25/How-to-Implement-Codegen/)
- [用 Dart 来写 Objective-C 代码](http://yulingtianxia.com/blog/2019/10/27/Write-Objective-C-Code-using-Dart/)
- [谈谈 dart_native 混合编程引擎的设计](http://yulingtianxia.com/blog/2019/11/28/DartObjC-Design/)
- [DartNative Memory Management: Object](http://yulingtianxia.com/blog/2019/12/26/DartObjC-Memory-Management-Object/)
- [DartNative Memory Management: C++ Non-Object](http://yulingtianxia.com/blog/2020/01/31/DartNative-Memory-Management-Cpp-Non-Object/)
- [DartNative Struct](http://yulingtianxia.com/blog/2020/02/24/DartNative-Struct/)
- [在 Flutter 中玩转 Objective-C Block](http://yulingtianxia.com/blog/2020/03/28/Using-Objective-C-Block-in-Flutter/)
- [Passing Out Parameter in DartNative](http://yulingtianxia.com/blog/2020/04/25/Passing-Out-Parameter-in-DartNative/)

## FAQs

Q: Failed to lookup symbol (dlsym(RTLD_DEFAULT, InitDartApiDL): symbol not found) on macOS archive.

A: Select one solution:
   1. Use dynamic library: Add `use_frameworks!` in Podfile.
   2. Select Target Runner -> Build Settings -> Strip Style -> change from "All Symbols" to "Non-Global Symbols"

## Contribution

- If you **need help** or you'd like to **ask a general question**, open an issue.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## License

DartNative is available under the BSD 3-Clause License. See the LICENSE file for more info.
