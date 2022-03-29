//
//  RuntimeStub.h
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ItemIndex) {
    ItemIndexNone = 0,
    ItemIndexOne = 1 << 0,
    ItemIndexTwo = 1 << 1,
};

@protocol SampleDelegate

- (NSString *)callback;
- (CGRect)callbackStruct:(CGRect)rect;

@end

typedef NSObject * _Nonnull (^BarBlock)(NSObject *a);
typedef CGAffineTransform (^StretBlock)(CGAffineTransform a);
typedef char * _Nonnull (^CStringRetBlock)(char *a);
typedef NSString * _Nonnull (^StringRetBlock)(NSString *a);
typedef NSDictionary *_Nonnull (^NSDictionaryRetBlock)(NSDictionary *a);
typedef CGFloat (^CGFloatRetBlock)(CGFloat a);

@interface RuntimeStub : NSObject

- (BOOL)fooBOOL:(BOOL)b;
- (int8_t)fooInt8:(int8_t)int8;
- (int16_t)fooInt16:(int16_t)int16;
- (int32_t)fooInt32:(int32_t)int32;
- (int64_t)fooInt64:(int64_t)int64;
- (uint8_t)fooUInt8:(uint8_t)uint8;
- (uint16_t)fooUInt16:(uint16_t)uint16;
- (uint32_t)fooUInt32:(uint32_t)uint32;
- (uint64_t)fooUInt64:(uint64_t)uint64;
- (float)fooFloat:(float)f;
- (double)fooDouble:(double)d;
- (char *)fooCharPtr:(char *)charPtr;
- (Class)fooClass:(Class)cls;
- (SEL)fooSEL:(SEL)sel;
- (id)fooObject:(id)object;
- (void *)fooPointer:(void *)p;
- (void)fooVoid;
- (CGSize)fooCGSize:(CGSize)size;
- (CGPoint)fooCGPoint:(CGPoint)point;
- (CGVector)fooCGVector:(CGVector)vector;
- (CGRect)fooCGRect:(CGRect)rect;
- (NSRange)fooNSRange:(NSRange)range;
#if TARGET_OS_IOS
- (UIOffset)fooUIOffset:(UIOffset)offset;
- (UIEdgeInsets)fooUIEdgeInsets:(UIEdgeInsets)insets;
#endif
- (NSDirectionalEdgeInsets)fooNSDirectionalEdgeInsets:(NSDirectionalEdgeInsets)insets
    API_AVAILABLE(ios(11.0), macos(10.15));
- (CGAffineTransform)fooCGAffineTransform:(CGAffineTransform)transform;
- (CATransform3D)fooCATransform3D:(CATransform3D)transform3D;
- (NSArray *)fooNSArray:(NSArray *)array;
- (NSMutableArray *)fooNSMutableArray:(NSMutableArray *)array;
- (NSDictionary *)fooNSDictionary:(NSDictionary *)dict;
- (NSMutableDictionary *)fooNSMutableDictionary:(NSMutableDictionary *)dict;
- (NSSet *)fooNSSet:(NSSet *)set;
- (NSMutableSet *)fooNSMutableSet:(NSMutableSet *)set;
- (void)fooBlock:(BarBlock)block;
- (void)fooStretBlock:(StretBlock)block;
- (void)fooCompletion:(void(^)(void))block;
- (void)fooCStringBlock:(CStringRetBlock)block;
- (void)fooStringBlock:(StringRetBlock)block;
- (void)fooNSDictionaryBlock:(NSDictionaryRetBlock)block;
- (void)fooDelegate:(id<SampleDelegate>)delegate;
- (void)fooStructDelegate:(id<SampleDelegate>)delegate;
- (NSString *)fooNSString:(NSString *)str;
- (NSMutableString *)fooNSMutableString:(NSMutableString *)str;
- (BOOL)fooWithError:(out NSError **)error;
- (ItemIndex)fooWithOptions:(ItemIndex)options;

@end

NS_ASSUME_NONNULL_END
