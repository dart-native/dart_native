//
//  DOPointerWrapper.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DOPointerWrapper.h"

@implementation DOPointerWrapper

- (void)dealloc {
    free(_pointer);
}

@end
