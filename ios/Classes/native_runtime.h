//
//  native_runtime.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/24.
//

#import "DOMacro.h"

#ifndef native_runtime_h
#define native_runtime_h

DO_EXTERN
NSMethodSignature *
native_method_signature(id object, SEL selector, const char **typeEncodings);

DO_EXTERN
BOOL
native_add_method(id target, SEL selector, Protocol *proto, void *callback);

DO_EXTERN
Class
native_get_class(const char *className, Class baseClass);

DO_EXTERN
void *
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, void **args);

DO_EXTERN
void *
native_block_create(char *types, void *callback);

DO_EXTERN
void *
native_block_invoke(void *block, void **args);

DO_EXTERN
const char *
native_type_encoding(const char *str);

DO_EXTERN
const char **
native_types_encoding(const char *str, int *count, int startIndex);

DO_EXTERN
const char *
native_struct_encoding(const char *encoding);

DO_EXTERN
bool
LP64(void);

DO_EXTERN
bool
NS_BUILD_32_LIKE_64(void);

#endif /* native_runtime_h */
