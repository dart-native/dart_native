//
//  DNTypeEncoding.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/17.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A port is used to send or receive inter-isolate messages
 */
typedef int64_t Dart_Port;
typedef struct _Dart_Handle* Dart_Handle;

NATIVE_TYPE_EXTERN const char * const native_type_sint8;
NATIVE_TYPE_EXTERN const char * const native_type_sint16;
NATIVE_TYPE_EXTERN const char * const native_type_sint32;
NATIVE_TYPE_EXTERN const char * const native_type_sint64;
NATIVE_TYPE_EXTERN const char * const native_type_uint8;
NATIVE_TYPE_EXTERN const char * const native_type_uint16;
NATIVE_TYPE_EXTERN const char * const native_type_uint32;
NATIVE_TYPE_EXTERN const char * const native_type_uint64;
NATIVE_TYPE_EXTERN const char * const native_type_float32;
NATIVE_TYPE_EXTERN const char * const native_type_float64;
NATIVE_TYPE_EXTERN const char * const native_type_object;
NATIVE_TYPE_EXTERN const char * const native_type_class;
NATIVE_TYPE_EXTERN const char * const native_type_selector;
NATIVE_TYPE_EXTERN const char * const native_type_block;
NATIVE_TYPE_EXTERN const char * const native_type_char_ptr;
NATIVE_TYPE_EXTERN const char * const native_type_void;
NATIVE_TYPE_EXTERN const char * const native_type_ptr;
NATIVE_TYPE_EXTERN const char * const native_type_bool;
NATIVE_TYPE_EXTERN const char * const native_type_string;

DN_EXTERN const char *DNSizeAndAlignment(const char *str, NSUInteger * _Nullable sizep, NSUInteger * _Nullable alignp, long * _Nullable lenp);

DN_EXTERN int DNTypeCount(const char *str);

DN_EXTERN int DNTypeLengthWithTypeName(NSString *typeName);

DN_EXTERN NSString * _Nullable DNTypeEncodeWithTypeName(NSString *typeName);

DN_EXTERN const char * _Nonnull * _Nonnull native_all_type_encodings(void);

DN_EXTERN const char *native_type_encoding(const char *str);

DN_EXTERN const char * _Nonnull * _Nullable native_types_encoding(const char *str, int * _Nullable count, int startIndex);

DN_EXTERN const char * _Nullable native_struct_encoding(const char *encoding);

NS_ASSUME_NONNULL_END
