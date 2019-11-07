//
//  RuntimeStub.m
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import "RuntimeStub.h"
#import <UIKit/UIKit.h>


@protocol StubDelegate <NSObject>

- (NSObject *)callback;

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

- (BOOL)fooBOOL:(BOOL)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return a;
}

- (int8_t)fooInt8:(int8_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return -123;
}

- (int16_t)fooInt16:(int16_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return -12345;
}

- (int32_t)fooInt32:(int32_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return -123456;
}

- (int64_t)fooInt64:(int64_t)a
{
    NSLog(@"%s arg: %lld", __FUNCTION__, a);
    return -123456;
}

- (uint8_t)fooUInt8:(uint8_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return 123;
}

- (uint16_t)fooUInt16:(uint16_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return 12345;
}

- (uint32_t)fooUInt32:(uint32_t)a
{
    NSLog(@"%s arg: %d", __FUNCTION__, a);
    return 123456;
}

- (uint64_t)fooUInt64:(uint64_t)a
{
    NSLog(@"%s arg: %llu", __FUNCTION__, a);
    return 123456;
}

- (float)fooFloat:(float)a
{
    NSLog(@"%s arg: %f", __FUNCTION__, a);
    return 123.456;
}

- (double)fooDouble:(double)a
{
    NSLog(@"%s arg: %f", __FUNCTION__, a);
    return 123.456;
}

- (char)fooChar:(char)a
{
    NSLog(@"%s arg: %c", __FUNCTION__, a);
    return a;
}

- (unsigned char)fooUChar:(unsigned char)a
{
    NSLog(@"%s arg: %c", __FUNCTION__, a);
    return a;
}

- (char *)fooCharPtr:(char *)a
{
    NSLog(@"%s arg: %s", __FUNCTION__, a);
    return a;
}

- (Class)fooClass:(Class)a
{
    NSLog(@"%s arg: %@", __FUNCTION__, a);
    return [RuntimeStub class];
}

- (SEL)fooSEL:(SEL)a
{
    NSLog(@"%s arg: %@", __FUNCTION__, NSStringFromSelector(a));
    return _cmd;
}

- (id)fooObject:(id)a
{
    NSLog(@"%s arg: %@", __FUNCTION__, a);
    return self.object;
}

- (void *)fooPointer:(void *)a
{
    NSLog(@"%s arg: %@", __FUNCTION__, a);
    return (__bridge void *)(self);
}

- (void)fooVoid
{
    NSLog(@"%s called", __FUNCTION__);
}

- (CGRect)fooCGRect:(CGRect)rect
{
    NSLog(@"%s %f, %f, %f, %f", __FUNCTION__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return (CGRect){1, 2, 3, 4};
}

typedef NSObject *(^BarBlock)(NSObject *a);

- (BarBlock)fooBlock:(BarBlock)block
{
    NSObject *arg = [NSObject new];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSObject *result = block(arg);
        NSLog(@"%s result: %@", __FUNCTION__, result);
    });
    
    BarBlock bar = ^(NSObject *a) {
        NSLog(@"bar block arg: %@ %@", a, arg);
        return a;
    };
    
    return bar;
}

- (void)fooDelegate:(id<StubDelegate>)delegate
{
    NSLog(@"%s arg: %@", __FUNCTION__, delegate);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSObject *result = [delegate callback];
        NSLog(@"%s callback result:%@", __FUNCTION__, result);
    });
}

- (NSString *)fooNSString:(NSString *)str
{
    NSLog(@"%s arg: %@", __FUNCTION__, str);
    return @"test nsstring";
}

@end


