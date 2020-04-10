# dart_native

Write native code using Dart. This package liberates you from native code and low performance channel.

Still under development!!! 

[![pub package](https://img.shields.io/pub/v/dart_native.svg)](https://pub.dev/packages/dart_native)
[![Build Status](https://travis-ci.org/dart-native/dart_native.svg?branch=master)](https://travis-ci.org/dart-native/dart_native)

## Requirements

Flutter 1.12.13 (Dart 2.7.0)

## Getting Started

Dart code:

```
// new Objective-C object.
RuntimeStub stub = RuntimeStub();

// Define Dart function according to Objective-C BarBlock signature.
Function testFunc = (NSObject a) {
    print('hello block! ${a.toString()}');
    return 101;
};

// Dart function will be converted to Objective-C block.
Block block = stub.fooBlock(testFunc);
// invoke Objective-C block.
int result = block.invoke([stub]);
print(result); 

// support built-in structs.
CGRect rect = stub.fooCGRect(CGRect(4, 3, 2, 1));
print(rect);

```

Objective-C code:

```
@interface RuntimeStub ()
@end
@implementation RuntimeStub
- (CGRect)fooCGRect:(CGRect)rect {
    NSLog(@"%s %f, %f, %f, %f", __func__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return (CGRect){1, 2, 3, 4};
}

typedef int(^BarBlock)(NSObject *a);

- (BarBlock)fooBlock:(BarBlock)block {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        int result = block([NSObject new]);
        NSLog(@"---result: %d", result);
    });
    BarBlock bar = ^(NSObject *a) {
        NSLog(@"bar block arg: %@", a);
        return 404;
    };
    return bar;
}
@end
```

## TODO List

- [ ] Generate Dart code from ObjectiveC/C++ Headers.
- [ ] Unit test.
- [ ] Documents.

## Article

- [用 Dart 来写 Objective-C 代码](http://yulingtianxia.com/blog/2019/10/27/Write-Objective-C-Code-using-Dart/)
- [谈谈 dart_objc 混合编程引擎的设计](http://yulingtianxia.com/blog/2019/11/28/DartObjC-Design/)
- [DartNative Memory Management: Object](http://yulingtianxia.com/blog/2019/12/26/DartObjC-Memory-Management-Object/)
- [DartNative Memory Management: C++ Non-Object](http://yulingtianxia.com/blog/2020/01/31/DartNative-Memory-Management-Cpp-Non-Object/)
- [DartNative Struct](http://yulingtianxia.com/blog/2020/02/24/DartNative-Struct/)
- [在 Flutter 中玩转 Objective-C Block](http://yulingtianxia.com/blog/2020/03/28/Using-Objective-C-Block-in-Flutter/)