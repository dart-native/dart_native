//
//  DNMacro.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#ifndef DNMacro_h
#define DNMacro_h

#ifdef __cplusplus
#define DN_EXTERN        extern "C" __attribute__((visibility("default"))) __attribute((used))
#else
#define DN_EXTERN            extern __attribute__((visibility("default"))) __attribute((used))
#endif

#ifdef __cplusplus
#define NATIVE_TYPE_EXTERN extern "C"
#else
#define NATIVE_TYPE_EXTERN extern
#endif

#define DN_INTERFACE(name)                                                     \
    + (instancetype)sharedInstanceForDartNative {                              \
        static dispatch_once_t onceToken;                                      \
        static id instance = nil;                                              \
        dispatch_once(&onceToken, ^{                                           \
            instance = [[[self class] alloc] init];                            \
        }); \
        return instance;                                                       \
    } \
    + (void)load {                                                             \
        DN_EXTERN BOOL DartNativeRegisterInterface(NSString *name, Class cls); \
        DartNativeRegisterInterface(@#name, self);                             \
    }

#define DN_INTERFACE_METHOD(name, method) DN_REGISTER_METHOD(name, method, __LINE__, __COUNTER__)

#define DN_REGISTER_METHOD(name, method, line, count) \
    DN_EXPORT_METHOD(name, method, line, count)       \
    - (id)method

#define DN_EXPORT_METHOD(name, method, line, count)                    \
    + (NSArray<NSString *> *)dn_interface_method_##name##line##count { \
        return @[@#name, @#method];                                    \
    }

#endif /* DNMacro_h */
