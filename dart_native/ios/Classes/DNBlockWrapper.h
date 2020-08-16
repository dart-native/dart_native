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

typedef void (*NativeBlockCallback)(void *_Nullable *_Null_unspecified args, void *ret, int numberOfArguments, BOOL stret);

@interface DNBlockWrapper : NSObject

@property (nonatomic, readonly) const char *_Nonnull *_Nonnull typeEncodings;
@property (nonatomic, readonly) NativeBlockCallback callback;
@property (nonatomic, getter=hasStret, readonly) BOOL stret;

- (int64_t)blockAddress;

- (instancetype)initWithTypeString:(char *)typeString
                          callback:(NativeBlockCallback)callback;

@end

NS_ASSUME_NONNULL_END
