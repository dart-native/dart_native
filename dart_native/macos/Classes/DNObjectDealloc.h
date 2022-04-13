//
//  DNObjectDealloc.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNAssociatedDartObject.h"

NS_ASSUME_NONNULL_BEGIN

/// Lifecycle of object on per isolate
@interface DNObjectDealloc : DNAssociatedDartObject

+ (instancetype)objectForHost:(NSObject *)host;
+ (nullable instancetype)attachHost:(NSObject *)host
                           dartPort:(Dart_Port)dartPort;

@end

NS_ASSUME_NONNULL_END
