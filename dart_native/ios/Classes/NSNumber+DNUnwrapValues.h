//
//  NSValue+DNUnwrapValues.h
//  dart_native
//
//  Created by 杨萧玉 on 2022/2/20.
//

#import <Foundation/Foundation.h>
#import "DNError.h"

#define CStringEquals(stringA, stringB) (strcmp(stringA, stringB) == 0)

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (DNUnwrapValues)

- (BOOL)dn_fillBuffer:(void * _Nullable * _Nonnull)buffer
             encoding:(const char *)encoding
                error:(out NSError **)error;
+ (instancetype)dn_numberWithBuffer:(void *)buffer
                           encoding:(const char *)type
                              error:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END
