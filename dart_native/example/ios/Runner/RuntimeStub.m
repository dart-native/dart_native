//
//  RuntimeStub.m
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import "RuntimeStub.h"
#import <UIKit/UIKit.h>
@import CocoaLumberjack;

#ifdef DEBUG
  static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
  static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#endif

@interface RuntimeStub ()<SampleDelegate>

@property (nonatomic) id object;

@end

@implementation RuntimeStub

- (instancetype)init {
    self = [super init];
    if (self) {
        _object = [NSObject new];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:@"SampleDartNotification" object:nil];
        });
    }
    return self;
}

- (BOOL)fooBOOL:(BOOL)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return a;
}

- (int8_t)fooInt8:(int8_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return -123;
}

- (int16_t)fooInt16:(int16_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return -12345;
}

- (int32_t)fooInt32:(int32_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return -123456;
}

- (int64_t)fooInt64:(int64_t)a {
    DDLogInfo(@"%s arg: %lld", __FUNCTION__, a);
    return -123456;
}

- (uint8_t)fooUInt8:(uint8_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return 123;
}

- (uint16_t)fooUInt16:(uint16_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return 12345;
}

- (uint32_t)fooUInt32:(uint32_t)a {
    DDLogInfo(@"%s arg: %d", __FUNCTION__, a);
    return 123456;
}

- (uint64_t)fooUInt64:(uint64_t)a {
    DDLogInfo(@"%s arg: %llu", __FUNCTION__, a);
    return 123456;
}

- (float)fooFloat:(float)a {
    DDLogInfo(@"%s arg: %f", __FUNCTION__, a);
    return 123.456;
}

- (double)fooDouble:(double)a {
    DDLogInfo(@"%s arg: %f", __FUNCTION__, a);
    return 123.456;
}

- (char *)fooCharPtr:(char *)a {
    DDLogInfo(@"%s arg: %s", __FUNCTION__, a);
    return a;
}

- (Class)fooClass:(Class)a {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, a);
    return [RuntimeStub class];
}

- (SEL)fooSEL:(SEL)a {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, NSStringFromSelector(a));
    return _cmd;
}

- (id)fooObject:(id)a {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, a);
    return self.object;
}

- (void *)fooPointer:(void *)a {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, a);
    return (__bridge void *)(self);
}

- (void)fooVoid {
    DDLogInfo(@"%s called", __FUNCTION__);
}

- (CGSize)fooCGSize:(CGSize)size {
    DDLogInfo(@"%s %f, %f", __FUNCTION__, size.width, size.height);
    return (CGSize){1.2345, 2.3456};
}

- (CGPoint)fooCGPoint:(CGPoint)point {
    DDLogInfo(@"%s %f, %f", __FUNCTION__, point.x, point.y);
    return (CGPoint){1.2345, 2.3456};
}

- (CGVector)fooCGVector:(CGVector)vector {
    DDLogInfo(@"%s %f, %f", __FUNCTION__, vector.dx, vector.dy);
    return (CGVector){1.2345, 2.3456};
}

- (CGRect)fooCGRect:(CGRect)rect {
    DDLogInfo(@"%s %f, %f, %f, %f", __FUNCTION__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    return (CGRect){1, 2, 3, 4};
}

- (NSRange)fooNSRange:(NSRange)range {
    DDLogInfo(@"%s %lu, %lu", __FUNCTION__, (unsigned long)range.location, (unsigned long)range.length);
    return (NSRange){12345, 23456};
}

- (UIOffset)fooUIOffset:(UIOffset)offset {
    DDLogInfo(@"%s %f, %f", __FUNCTION__, offset.horizontal, offset.vertical);
    return (UIOffset){1.2345, 2.3456};
}

- (UIEdgeInsets)fooUIEdgeInsets:(UIEdgeInsets)insets {
    DDLogInfo(@"%s %f, %f, %f, %f", __FUNCTION__, insets.top, insets.left, insets.bottom, insets.right);
    return (UIEdgeInsets){1, 2, 3, 4};
}

- (NSDirectionalEdgeInsets)fooNSDirectionalEdgeInsets:(NSDirectionalEdgeInsets)insets
API_AVAILABLE(ios(11.0)){
    DDLogInfo(@"%s %f, %f, %f, %f", __FUNCTION__, insets.top, insets.leading, insets.bottom, insets.trailing);
    return (NSDirectionalEdgeInsets){1, 2, 3, 4};
}

- (CGAffineTransform)fooCGAffineTransform:(CGAffineTransform)transform {
    DDLogInfo(@"%s %f, %f, %f, %f, %f, %f", __FUNCTION__, transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
    return (CGAffineTransform){1.1, 2.2, 3.3, 4.4, 5.5, 6.6};
}

- (NSArray *)fooNSArray:(NSArray *)array {
    DDLogInfo(@"%s %@", __FUNCTION__, array.description);
    return array;
}

- (NSMutableArray *)fooNSMutableArray:(NSMutableArray *)array {
    DDLogInfo(@"%s %@", __FUNCTION__, array.description);
    [array addObject:@"mutable!"];
    return array;
}

- (NSDictionary *)fooNSDictionary:(NSDictionary *)dict {
    DDLogInfo(@"%s %@", __FUNCTION__, dict.description);
    return dict;
}

- (NSMutableDictionary *)fooNSMutableDictionary:(NSMutableDictionary *)dict {
    DDLogInfo(@"%s %@", __FUNCTION__, dict.description);
    dict[@"newKey"] = @"mutable!";
    return dict;
}

- (NSSet *)fooNSSet:(NSSet *)set {
    DDLogInfo(@"%s %@", __FUNCTION__, set.description);
    return set;
}

- (NSMutableSet *)fooNSMutableSet:(NSMutableSet *)set {
    DDLogInfo(@"%s %@", __FUNCTION__, set.description);
    [set addObject:@"mutable!"];
    return set;
}

- (void)fooBlock:(BarBlock)block {
    NSObject *arg = [NSObject new];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (block) {
            NSObject *result = block(@"123123");
            DDLogInfo(@"%s result: %@", __FUNCTION__, result);
        }
    });
}

- (void)fooStretBlock:(StretBlock)block {
    CGAffineTransform arg = CGAffineTransformMake(1.1, 2.2, 3.3, 4.4, 5.5, 6.6);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (block) {
            CGAffineTransform result = block(arg);
            DDLogInfo(@"%s result: %@", __FUNCTION__, NSStringFromCGAffineTransform(result));
        }
    });
}

- (void)fooCStringBlock:(CStringRetBlock)block {
    char *arg = "test c-string";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        if (block) {
            char *result = block(arg);
            DDLogInfo(@"%s result: %s", __FUNCTION__, result);
        }
    });
}

- (void)fooDelegate:(id<SampleDelegate>)delegate {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, delegate);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        NSObject *result = [delegate callback];
        DDLogInfo(@"%s callback result:%@", __FUNCTION__, result);
    });
}

- (void)fooStructDelegate:(id<SampleDelegate>)delegate {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, delegate);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        CGRect result = [delegate callbackStruct:CGRectMake(1.1, 2.2, 3.3, 4.4)];
        DDLogInfo(@"%s callback result:%@", __FUNCTION__, NSStringFromCGRect(result));
    });
}

- (NSString *)fooNSString:(NSString *)str {
    DDLogInfo(@"%s arg: %@", __FUNCTION__, str);
    return @"test nsstring";
}

- (NSMutableString *)fooNSMutableString:(NSMutableString *)str {
    [str appendString:@" mutable!"];
    DDLogInfo(@"%s arg: %@", __FUNCTION__, str);
    return str;
}

- (void)fooWithError:(out NSError **)error {
    if (error) {
        *error = [NSError errorWithDomain:@"com.dartnative.test" code:-1 userInfo:nil];
    }
}

- (TestOptions)fooWithOptions:(TestOptions)options {
    return options;
}

@end


