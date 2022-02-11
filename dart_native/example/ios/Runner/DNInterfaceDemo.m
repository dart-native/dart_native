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

@implementation DNInterfaceDemo

DN_INTERFACE_ENTRY(MyFirstInterface)

DN_INTERFACE_METHOD(hello, myHello:(NSString *)str) {
    return [NSString stringWithFormat:@"hello %@!", str];
}

DN_INTERFACE_METHOD(sum, addA:(int32_t)a withB:(int32_t)b) {
    return @(a + b);
}

DN_INTERFACE_METHOD(testCallback, performBlock:(void(^)(BOOL success, NSString *result))block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (block) {
            block(YES, @"callback from native");
        }
    });
    return nil;
}

@end
