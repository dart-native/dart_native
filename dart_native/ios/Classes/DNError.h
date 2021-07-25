//
//  DNError.h
//  DartNative
//
//  Created by 杨萧玉 on 2021/4/19.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"

#define DN_ERROR(errorCode, desc, ...) \
if (error) { \
    NSString *reason = [NSString stringWithFormat:desc, ##__VA_ARGS__]; \
    NSLog(desc, ##__VA_ARGS__);\
    NSError *underlyingError = [NSError errorWithDomain:DNErrorDomain\
                                                   code:errorCode\
                                               userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];\
    *error = DNErrorWithUnderlyingError(*error, underlyingError); \
}

NS_ASSUME_NONNULL_BEGIN

/// MARK: Error
extern NSErrorDomain const DNErrorDomain;

typedef NS_ERROR_ENUM(DNErrorDomain, DNErrorCode) {
    DNCreateTypeEncodingError = 1, // creating type encoding fail.
    DNCreateBlockError, // creating block fail.
};

DN_EXTERN NSError *DNErrorWithUnderlyingError(NSError *error, NSError *underlyingError);

NS_ASSUME_NONNULL_END
