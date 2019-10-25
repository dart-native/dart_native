//
//  Wrapper-Interface.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/23.
//

#ifndef Wrapper_Interface_h
#define Wrapper_Interface_h

DO_EXTERN
int DOTypeCount(const char *str);

DO_EXTERN
const char *DOSizeAndAlignment(const char *str, NSUInteger *sizep, NSUInteger *alignp, long *lenp);

DO_EXTERN
const char *DOBlockTypeEncodeString(id blockObj);

#endif /* Wrapper_Interface_h */
