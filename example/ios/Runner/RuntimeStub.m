//
//  RuntimeStub.m
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import "RuntimeStub.h"
#import <UIKit/UIKit.h>


@protocol StubDelegate <NSObject>

- (void)callback;

@end

@interface RuntimeStub ()<StubDelegate>

@property (nonatomic) id object;

@end

@implementation RuntimeStub

- (instancetype)init
{
    self = [super init];
    if (self) {
        _object = [NSObject new];
    }
    return self;
}

- (int8_t)fooInt8:(int8_t)a
{
    NSLog(@"arg: %d", a);
    return -123;
}

- (int16_t)fooInt16:(int16_t)a
{
    NSLog(@"arg: %d", a);
    return -12345;
}

- (int32_t)fooInt32:(int32_t)a
{
    NSLog(@"arg: %d", a);
    return -123456;
}

- (int64_t)fooInt64:(int64_t)a
{
    NSLog(@"arg: %lld", a);
    return -123456;
}

- (uint8_t)fooUInt8:(uint8_t)a
{
    NSLog(@"arg: %d", a);
    return 123;
}

- (uint16_t)fooUInt16:(uint16_t)a
{
    NSLog(@"arg: %d", a);
    return 12345;
}

- (uint32_t)fooUInt32:(uint32_t)a
{
    NSLog(@"arg: %d", a);
    return 123456;
}

- (uint64_t)fooUInt64:(uint64_t)a
{
    NSLog(@"arg: %llu", a);
    return 123456;
}

- (float)fooFloat:(float)a
{
    NSLog(@"arg: %f", a);
    return 123.456;
}

- (double)fooDouble:(double)a
{
    NSLog(@"arg: %f", a);
    return 123.456;
}

- (char)fooChar:(char)a
{
    NSLog(@"arg: %c", a);
    return 'c';
}

- (char *)fooCharPtr:(char *)a
{
    NSLog(@"arg: %s", a);
    return "123456";
}

- (Class)fooClass:(Class)a
{
    NSLog(@"arg: %@", a);
    return [RuntimeStub class];
}

- (SEL)fooSEL:(SEL)a
{
    NSLog(@"arg: %@", NSStringFromSelector(a));
    return _cmd;
}

- (id)fooObject:(id)a
{
    NSLog(@"arg: %@", a);
    return self.object;
}

- (void *)fooPointer:(void *)a
{
    NSLog(@"arg: %@", a);
    return (__bridge void *)(self);
}

- (void)fooVoid
{
    NSLog(@"foo15 called");
    return;
}

- (CGRect)fooCGRect:(CGRect)rect
{
    NSLog(@"%s %f, %f, %f, %f", __func__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return (CGRect){1, 2, 3, 4};
}

typedef int(^BarBlock)(NSObject *a);

- (BarBlock)fooBlock:(BarBlock)block
{
    NSObject *arg = [NSObject new];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        int result = block(arg);
        NSLog(@"---result: %d", result);
    });
    
    BarBlock bar = ^(NSObject *a) {
        NSLog(@"bar block arg: %@ %@", a, arg);
        return 404;
    };
    
    return bar;
}

- (void)fooDelegate:(id<StubDelegate>)delegate
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [delegate callback];
    });
}

- (NSString *)fooNSString:(NSString *)str
{
    NSLog(@"%@", str);
    return @"test nsstring";
}

@end


