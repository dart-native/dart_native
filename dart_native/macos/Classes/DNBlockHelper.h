//
//  DNBlockHelper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import "DNInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface DNBlockHelper : NSObject

+ (void)invokeInterfaceBlock:(void *)block
                   arguments:(NSArray *)arguments
                      result:(nullable BlockResultCallback)resultCallback;
+ (BOOL)testNotifyDart:(int64_t)port;

@end

NS_ASSUME_NONNULL_END
