//
//  DOMacro.h
//  Pods
//
//  Created by 杨萧玉 on 2019/10/30.
//

#ifndef DOMacro_h
#define DOMacro_h

#ifdef __cplusplus
#define DO_EXTERN        extern "C" __attribute__((visibility("default"))) __attribute((used))
#else
#define DO_EXTERN            extern __attribute__((visibility("default"))) __attribute((used))
#endif

#endif /* DOMacro_h */
