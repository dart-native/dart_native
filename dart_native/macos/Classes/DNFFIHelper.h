//
//  DNFFIHelper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNFFIHelper : NSObject

- (ffi_type *_Nullable)ffiTypeForStructEncode:(const char *)str;
- (ffi_type *_Nullable)ffiTypeForEncode:(const char *)str;

- (ffi_type *_Nonnull*_Nullable)argsWithEncodeString:(const char *)str getCount:(int *)outCount;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start;
- (ffi_type *_Nonnull*_Nullable)typesWithEncodeString:(const char *)str getCount:(int *)outCount startIndex:(int)start nullAtEnd:(BOOL)nullAtEnd;

@end

NS_ASSUME_NONNULL_END
