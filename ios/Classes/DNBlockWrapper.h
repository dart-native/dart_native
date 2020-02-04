//
//  DNBlockWrapper.h
//  dart_native
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"

NS_ASSUME_NONNULL_BEGIN

DN_EXTERN
const char *DNBlockTypeEncodeString(id blockObj);

@interface DNBlockWrapper : NSObject

- (int64_t)blockAddress;

- (instancetype)initWithTypeString:(char *)typeString callback:(void *)callback;

@end

NS_ASSUME_NONNULL_END
