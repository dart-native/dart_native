//
//  RuntimeStub.m
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import "RuntimeStub.h"
#import <UIKit/UIKit.h>

@interface RuntimeStub ()

@property (nonatomic) id stub;

@end

@implementation RuntimeStub

- (instancetype)init
{
    self = [super init];
    if (self) {
        _stub = [NSObject new];
    }
    return self;
}

- (int8_t)foo0:(int8_t)a
{
    NSLog(@"arg: %d", a);
    return -123;
}

- (int16_t)foo1:(int16_t)a
{
    NSLog(@"arg: %d", a);
    return -12345;
}

- (int32_t)foo2:(int32_t)a
{
    NSLog(@"arg: %d", a);
    return -123456;
}

- (int64_t)foo3:(int64_t)a
{
    NSLog(@"arg: %lld", a);
    return -123456;
}

- (uint8_t)foo4:(uint8_t)a
{
    NSLog(@"arg: %d", a);
    return 123;
}

- (uint16_t)foo5:(uint16_t)a
{
    NSLog(@"arg: %d", a);
    return 12345;
}

- (uint32_t)foo6:(uint32_t)a
{
    NSLog(@"arg: %d", a);
    return 123456;
}

- (uint64_t)foo7:(uint64_t)a
{
    NSLog(@"arg: %llu", a);
    return 123456;
}

- (float)foo8:(float)a
{
    NSLog(@"arg: %f", a);
    return 123.456;
}

- (double)foo9:(double)a
{
    NSLog(@"arg: %f", a);
    return 123.456;
}

- (char *)foo10:(char *)a
{
    NSLog(@"arg: %s", a);
    return "123456";
}

- (Class)foo11:(Class)a
{
    NSLog(@"arg: %@", a);
    return [RuntimeStub class];
}

- (SEL)foo12:(SEL)a
{
    NSLog(@"arg: %@", NSStringFromSelector(a));
    return _cmd;
}

- (id)foo13:(id)a
{
    NSLog(@"arg: %@", a);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"%@, Retain count is %ld", stub, CFGetRetainCount(stub));
    });
    return self.stub;
}

- (void *)foo14:(void *)a
{
    NSLog(@"arg: %@", a);
    return (__bridge void *)(self);
}

- (void)foo15
{
    NSLog(@"foo15 called");
    return;
}

- (void)fooBlock:(int(^)(CGSize a))block
{
    CGSize a = (CGSize){12.345, 54.321};
    int result = block(a);
    NSLog(@"%d", result);
}

@end
