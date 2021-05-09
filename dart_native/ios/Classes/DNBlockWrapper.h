//
//  DNBlockWrapper.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import "DNMacro.h"
#import "dart_api_dl.h"

NS_ASSUME_NONNULL_BEGIN

DN_EXTERN
const char *DNBlockTypeEncodeString(id blockObj);

typedef void (*NativeBlockCallback)(void *_Nullable *_Null_unspecified args, void *ret, int numberOfArguments, BOOL stret, int64_t seq);

@interface DNBlockWrapper : NSObject

@property (nonatomic, readonly) const char *_Nonnull *_Nonnull typeEncodings;
@property (nonatomic, readonly) NativeBlockCallback callback;
@property (nonatomic, getter=hasStret, readonly) BOOL stret;
@property (nonatomic, readonly) int64_t sequence;
@property (nonatomic, readonly) Dart_Port dartPort;

- (intptr_t)blockAddress;

- (instancetype)initWithTypeString:(char *)typeString
                          callback:(NativeBlockCallback)callback
                          dartPort:(Dart_Port)dartPort
                             error:(out NSError **)error;

@end

NS_ASSUME_NONNULL_END
