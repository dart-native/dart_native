//
//  NSThread+DartNative.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (DartNative)

// If self is not the current thread, the block will be called asynchronously
// and this method returns immediately.
// If self is the current thread, the block will be performed immediately, and
// then this method will return.
- (void)dn_performBlock:(void (^)(void))block;

- (void)dn_performWaitingUntilDone:(BOOL)waitDone block:(void (^)(void))block;
+ (void)dn_performBlockInBackground:(void (^)(void))block;

@end

NS_ASSUME_NONNULL_END
