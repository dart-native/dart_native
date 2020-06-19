//
//  RuntimeStub.h
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, TestOptions) {
    TestOptionsNone = 0,
    TestOptionsOne = 1 << 0,
    TestOptionsTwo = 1 << 1,
};

@protocol SampleDelegate

- (NSObject *)callback;
- (CGRect)callbackStruct:(CGRect)rect;

@end

typedef NSObject * _Nonnull (^BarBlock)(NSObject *a);
typedef CGAffineTransform (^StretBlock)(CGAffineTransform a);
typedef char * _Nonnull (^CStringRetBlock)(char *a);

@interface RuntimeStub : NSObject

- (BOOL)fooBOOL:(BOOL)a;
- (int8_t)fooInt8:(int8_t)a;
- (int16_t)fooInt16:(int16_t)a;
- (int32_t)fooInt32:(int32_t)a;
- (int64_t)fooInt64:(int64_t)a;
- (uint8_t)fooUInt8:(uint8_t)a;
- (uint16_t)fooUInt16:(uint16_t)a;
- (uint32_t)fooUInt32:(uint32_t)a;
- (uint64_t)fooUInt64:(uint64_t)a;
- (float)fooFloat:(float)a;
- (double)fooDouble:(double)a;
- (char *)fooCharPtr:(char *)a;
- (Class)fooClass:(Class)a;
- (SEL)fooSEL:(SEL)a;
- (id)fooObject:(id)a;
- (void *)fooPointer:(void *)a;
- (void)fooVoid;
- (CGSize)fooCGSize:(CGSize)size;
- (CGPoint)fooCGPoint:(CGPoint)point;
- (CGVector)fooCGVector:(CGVector)vector;
- (CGRect)fooCGRect:(CGRect)rect;
- (NSRange)fooNSRange:(NSRange)range;
- (UIOffset)fooUIOffset:(UIOffset)offset;
- (UIEdgeInsets)fooUIEdgeInsets:(UIEdgeInsets)insets;
- (NSDirectionalEdgeInsets)fooNSDirectionalEdgeInsets:(NSDirectionalEdgeInsets)insets
    API_AVAILABLE(ios(11.0));
- (CGAffineTransform)fooCGAffineTransform:(CGAffineTransform)transform;
- (NSArray *)fooNSArray:(NSArray *)array;
- (NSMutableArray *)fooNSMutableArray:(NSMutableArray *)array;
- (NSDictionary *)fooNSDictionary:(NSDictionary *)dict;
- (NSMutableDictionary *)fooNSMutableDictionary:(NSMutableDictionary *)dict;
- (NSSet *)fooNSSet:(NSSet *)set;
- (NSMutableSet *)fooNSMutableSet:(NSMutableSet *)set;
- (BarBlock)fooBlock:(BarBlock)block;
- (StretBlock)fooStretBlock:(StretBlock)block;
- (CStringRetBlock)fooCStringBlock:(CStringRetBlock)block;
- (void)fooDelegate:(id<SampleDelegate>)delegate;
- (void)fooStructDelegate:(id<SampleDelegate>)delegate;
- (NSString *)fooNSString:(NSString *)str;
- (NSMutableString *)fooNSMutableString:(NSMutableString *)str;
- (void)fooWithError:(out NSError **)error;
- (TestOptions)fooWithOptions:(TestOptions)options;

@end

NS_ASSUME_NONNULL_END
