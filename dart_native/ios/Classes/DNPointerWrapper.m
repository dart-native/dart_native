//
//  DNPointerWrapper.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNPointerWrapper.h"

#if !__has_feature(objc_arc)
#error
#endif

@implementation DNPointerWrapper

- (void)setPointer:(void *)pointer {
    _pointer = pointer;
}

- (void)dealloc {
    free(_pointer);
}

@end
