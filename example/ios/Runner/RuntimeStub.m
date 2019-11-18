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

- (CGSize)fooCGSize:(CGSize)size
{
    NSLog(@"%s %f, %f", __FUNCTION__, size.width, size.height);
    return (CGSize){1.2345, 2.3456};
}

- (CGPoint)fooCGPoint:(CGPoint)point
{
    NSLog(@"%s %f, %f", __FUNCTION__, point.x, point.y);
    return (CGPoint){1.2345, 2.3456};
}

- (CGVector)fooCGVector:(CGVector)vector
{
    NSLog(@"%s %f, %f", __FUNCTION__, vector.dx, vector.dy);
    return (CGVector){1.2345, 2.3456};
}

- (CGRect)fooCGRect:(CGRect)rect
{
    NSLog(@"%s %f, %f, %f, %f", __FUNCTION__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return (CGRect){1, 2, 3, 4};
}

- (NSRange)fooNSRange:(NSRange)range
{
    NSLog(@"%s %lu, %lu", __FUNCTION__, (unsigned long)range.location, (unsigned long)range.length);
    return (NSRange){12345, 23456};
}

- (UIOffset)fooUIOffset:(UIOffset)offset
{
    NSLog(@"%s %f, %f", __FUNCTION__, offset.horizontal, offset.vertical);
    return (UIOffset){1.2345, 2.3456};
}

- (UIEdgeInsets)fooUIEdgeInsets:(UIEdgeInsets)insets
{
    NSLog(@"%s %f, %f, %f, %f", __FUNCTION__, insets.top, insets.left, insets.bottom, insets.right);
    return (UIEdgeInsets){1, 2, 3, 4};
}

- (NSDirectionalEdgeInsets)fooNSDirectionalEdgeInsets:(NSDirectionalEdgeInsets)insets
API_AVAILABLE(ios(11.0)){
    NSLog(@"%s %f, %f, %f, %f", __FUNCTION__, insets.top, insets.leading, insets.bottom, insets.trailing);
    return (NSDirectionalEdgeInsets){1, 2, 3, 4};
}

- (CGAffineTransform)fooCGAffineTransform:(CGAffineTransform)transform
{
    NSLog(@"%s %f, %f, %f, %f, %f, %f", __FUNCTION__, transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
    return (CGAffineTransform){1.1, 2.2, 3.3, 4.4, 5.5, 6.6};
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


