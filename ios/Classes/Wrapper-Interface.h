//
//  Wrapper-Interface.h
//  Pods
//
//  Created by 杨萧玉 on 2019/10/23.
//

#ifndef Wrapper_Interface_h
#define Wrapper_Interface_h

extern "C" __attribute__((visibility("default"))) __attribute((used))
int DOTypeCount(const char *str);

extern "C" __attribute__((visibility("default"))) __attribute((used))
const char *DOSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, long *lenp);

#endif /* Wrapper_Interface_h */
