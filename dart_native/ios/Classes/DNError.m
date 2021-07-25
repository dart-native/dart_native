//
//  DNError.m
//  DartNative
//
//  Created by 杨萧玉 on 2021/4/19.
//

#import "DNError.h"

#if !__has_feature(objc_arc)
#error
#endif

/// MARK: Error
NSString * const DNErrorDomain = @"com.dartnative.bridge";

NSError *DNErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
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
