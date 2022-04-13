//
//  DNFFIHelper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import "ffi.h"
#import "DNMacro.h"

NS_ASSUME_NONNULL_BEGIN

DN_EXTERN
const char *DNSizeAndAlignment(const char *str, NSUInteger * _Nullable sizep, NSUInteger * _Nullable alignp, long * _Nullable lenp);

DN_EXTERN
int DNTypeCount(const char *str);

DN_EXTERN
int DNTypeLengthWithTypeName(NSString *typeName);

DN_EXTERN
NSString * _Nullable DNTypeEncodeWithTypeName(NSString *typeName);

@interface DNFFIHelper : NSObject

- (ffi_type *)ffiTypeForStructEncode:(const char *)str;
- (ffi_type *_Nullable)ffiTypeForEncode:(const char *)str;

- (ffi_type *_Nonnull*_Nullable)argsWithEncodeString:(const char *)str getCount:(int *)outCount;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd;

@end

NS_ASSUME_NONNULL_END
