//
//  DNError.h
//  DartNative
//
//  Created by 杨萧玉 on 2021/4/19.
//

#import <Foundation/Foundation.h>

#define DN_ERROR(desc, ...) \
if (error) { \
    NSString *reason = [NSString stringWithFormat:desc, ##__VA_ARGS__]; \
    NSError *underlyingError = [NSError errorWithDomain:DNErrorDomain\
                                                   code:DNCreateTypeEncodingError\
                                               userInfo:@{NSLocalizedFailureReasonErrorKey: reason}];\
    *error = DNErrorWithUnderlyingError(*error, underlyingError); \
}

NS_ASSUME_NONNULL_BEGIN

/// MARK: Error
extern NSErrorDomain const DNErrorDomain;

typedef NS_ERROR_ENUM(DNErrorDomain, DNErrorCode) {
    DNCreateTypeEncodingError = 1, // creating type encoding fail.
};

static NSError * DNErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    return [NSError errorWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

NS_ASSUME_NONNULL_END
