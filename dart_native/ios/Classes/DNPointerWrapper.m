//
//  DNPointerWrapper.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNPointerWrapper.h"
#import <malloc/malloc.h>
#import "dart_api_dl.h"

#if !__has_feature(objc_arc)
#error
#endif

@implementation DNPointerWrapper

- (instancetype)initWithPointer:(void *)pointer {
    self = [super init];
    if (self) {
        _pointer = pointer;
    }
    return self;
}

- (void)dealloc {
    free(_pointer);
}

@end
