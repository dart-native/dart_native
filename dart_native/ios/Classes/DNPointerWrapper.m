//
//  DNPointerWrapper.m
//  dart_native
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNPointerWrapper.h"

@implementation DNPointerWrapper

- (void)setPointer:(void *)pointer {
    _pointer = pointer;
}

- (void)dealloc {
    free(_pointer);
}

@end
