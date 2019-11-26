//
//  NSThread+DartObjC.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/11/26.
//

#import "NSThread+DartObjC.h"

@implementation NSThread (DartObjC)

+ (void)do_runBlockOnCurrentThread:(void (^)(void))block {
    block();
}

- (void)do_performBlock:(void (^)(void))block {
    if ([[NSThread currentThread] isEqual:self]) {
        block();
    } else {
        [self do_performWaitingUntilDone:NO block:block];
    }
}

- (void)do_performWaitingUntilDone:(BOOL)waitDone block:(void (^)(void))block {
    [NSThread performSelector:@selector(do_runBlockOnCurrentThread:)
                     onThread:self
                   withObject:block
                waitUntilDone:waitDone];
}

+ (void)do_performBlockInBackground:(void (^)(void))block {
    [NSThread performSelectorInBackground:@selector(do_runBlockOnCurrentThread:)
                               withObject:block];
}

@end
