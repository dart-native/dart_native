//
//  DNObjectDealloc.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import <Foundation/Foundation.h>
#import "dart_api_dl.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNObjectDealloc : NSObject

+ (void)attachHost:(NSObject *)host dartPort:(Dart_Port)dartPort;

@end

NS_ASSUME_NONNULL_END
