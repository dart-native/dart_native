//
//  DNMethodIMP.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import "dart_api_dl.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (*NativeMethodCallback)(void *_Nullable *_Null_unspecified args,
                                    void *ret,
                                    int numberOfArguments,
                                    const char *_Nonnull *_Nonnull types,
                                    BOOL stret);

@interface DNMethodIMP : NSObject

@property (nonatomic, readonly) NativeMethodCallback callback;
@property (nonatomic, getter=hasStret, readonly) BOOL stret;

- (instancetype)initWithTypeEncoding:(const char *)typeEncodings
                            callback:(NativeMethodCallback)callback
                               error:(NSError **)error;
- (IMP)imp;

@end

NS_ASSUME_NONNULL_END
