//
//  NSThread+DartNative.m
//  dart_native
//
//  Created by 杨萧玉 on 2019/11/26.
//

#import "NSThread+DartNative.h"

@implementation NSThread (DartNative)

+ (void)dn_runBlockOnCurrentThread:(void (^)(void))block {
    block();
}

- (void)dn_performBlock:(void (^)(void))block {
    if ([[NSThread currentThread] isEqual:self]) {
        block();
    } else {
        [self dn_performWaitingUntilDone:NO block:block];
    }
}

- (void)dn_performWaitingUntilDone:(BOOL)waitDone block:(void (^)(void))block {
    [NSThread performSelector:@selector(dn_runBlockOnCurrentThread:)
                     onThread:self
                   withObject:block
                waitUntilDone:waitDone];
}

+ (void)dn_performBlockInBackground:(void (^)(void))block {
    [NSThread performSelectorInBackground:@selector(dn_runBlockOnCurrentThread:)
                               withObject:block];
}

@end
