//
//  DNExtern.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#ifndef DNExtern_h
#define DNExtern_h

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

#endif /* DNExtern_h */
