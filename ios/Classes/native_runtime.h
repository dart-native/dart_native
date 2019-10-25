//
//  native_runtime.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/24.
//

#ifndef native_runtime_h
#define native_runtime_h

#ifdef __cplusplus
#define DO_EXTERN        extern "C" __attribute__((visibility("default"))) __attribute((used))
#else
#define DO_EXTERN            extern __attribute__((visibility("default"))) __attribute((used))
#endif

DO_EXTERN
void *
native_method_imp(const char *cls_str, const char *selector_str, bool isClassMethod);

DO_EXTERN
NSMethodSignature *
native_method_signature(id object, SEL selector, const char **typeEncodings);

DO_EXTERN
void *
native_instance_invoke(id object, SEL selector, NSMethodSignature *signature, void **args);

DO_EXTERN
void *
block_create(char *types, void *callback);

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
LP64();

DO_EXTERN
bool
NS_BUILD_32_LIKE_64();

#endif /* native_runtime_h */
