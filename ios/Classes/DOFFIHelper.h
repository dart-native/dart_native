//
//  DOFFIHelper.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import "ffi.h"
#import "DOMacro.h"

NS_ASSUME_NONNULL_BEGIN

DO_EXTERN
const char *DOSizeAndAlignment(const char *str, NSUInteger * _Nullable sizep, NSUInteger * _Nullable alignp, long * _Nullable lenp);

DO_EXTERN
int DOTypeCount(const char *str);

DO_EXTERN
int DOTypeLengthWithTypeName(NSString *typeName);

DO_EXTERN
NSString * _Nullable DOTypeEncodeWithTypeName(NSString *typeName);

@interface DOFFIHelper : NSObject

- (ffi_type *)ffiTypeForStructEncode:(const char *)str;
- (ffi_type *_Nullable)ffiTypeForEncode:(const char *)str;

- (ffi_type *_Nonnull*_Nullable)argsWithEncodeString:(const char *)str getCount:(int *)outCount;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd;

@end

NS_ASSUME_NONNULL_END
