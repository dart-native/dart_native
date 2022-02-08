//
//  DNInterfaceDemo.m
//  Runner
//
//  Created by 杨萧玉 on 2022/2/8.
//

#import "DNInterfaceDemo.h"
#if __has_include(<DartNative/DNMacro.h>)
#import <DartNative/DNMacro.h>
#else
@import dart_native;
#endif

@implementation DNInterfaceDemo

DN_INTERFACE(MyFirstInterface)

DN_INTERFACE_METHOD(hello, myHello:(NSString *)str) {
    return [NSString stringWithFormat:@"hello %@!", str];
}

DN_INTERFACE_METHOD(sum, addA:(int32_t)a withB:(int32_t)b) {
    return @(a + b);
}

@end
