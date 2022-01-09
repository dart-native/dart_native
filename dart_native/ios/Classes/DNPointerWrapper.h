//
//  DNPointerWrapper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// You can use this wrapper to bind lifecycle of heap memory on a NSObject instance.
@interface DNPointerWrapper : NSObject

@property (nonatomic, readonly) void *pointer;

/// Init by a pointer
/// @param pointer points to memory on heap
- (instancetype)initWithPointer:(void *)pointer;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
