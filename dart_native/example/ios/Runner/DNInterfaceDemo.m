//
//  DNInterfaceDemo.m
//  Runner
//
//  Created by 杨萧玉 on 2022/2/8.
//

#import "DNInterfaceDemo.h"
#if __has_include(<dart_native/DNInterfaceRegistry.h>)
#import <dart_native/DNInterfaceRegistry.h>
#else
@import dart_native;
#endif
#import "DNDartFinalizer.h"

@implementation DNInterfaceDemo
// Register interface name.
InterfaceEntry(MyFirstInterface) 
// Register method name.
InterfaceMethod(hello, myHello:(NSString *)str) {
    [self invokeMethod:@"totalCost"
             arguments:@[@0.123456789, @10, @[@"testArray"]]
                result:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"result: %@, error: %@", result, error);
    }];
    return [NSString stringWithFormat:@"hello %@!", str];
}

InterfaceMethod(sum, addA:(int32_t)a withB:(int32_t)b) {
    return @(a + b);
}

InterfaceMethod(getUTF8Data, utf8DataForString:(NSString *)str) {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

InterfaceMethod(testCallback, performBlock:(void(^)(BOOL success, NSString *result))block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (block) {
            block(YES, @"callback from native");
        }
    });
    return nil;
}

InterfaceMethod(finalizer, finalizerObject) {
    return [[DNDartFinalizer alloc] init];
}

@end


