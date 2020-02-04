//
//  DNMacro.h
//  Pods
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

#endif /* DNMacro_h */
