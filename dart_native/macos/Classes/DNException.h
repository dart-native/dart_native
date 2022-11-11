//
//  DNException.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/11/8.
//

#import <Foundation/Foundation.h>
#import "DNExtern.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const DNClassNotFoundExceptionReason;
extern NSExceptionName const DNClassNotFoundException;

/// Setup exception config
/// - Parameter canThrow: Whether to throw exceptions
void DartNativeSetThrowException(bool canThrow);

/// Whether to throw an exception
bool DartNativeCanThrowException(void);

NS_ASSUME_NONNULL_END
