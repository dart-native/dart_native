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

@property (nonatomic, getter=hasStret, readonly) BOOL stret;
@property (nonatomic, getter=isReturnString, readonly) BOOL returnString;
// Every dart port has its own callback.
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSNumber *> *callbackForDartPort;

- (instancetype)initWithTypeEncoding:(const char *)typeEncodings
                            callback:(NativeMethodCallback)callback
                        returnString:(BOOL)returnString
                            dartPort:(Dart_Port)dartPort
                               error:(NSError **)error;
- (void)addCallback:(NativeMethodCallback)callback forDartPort:(Dart_Port)port;
- (void)removeCallbackForDartPort:(Dart_Port)port;
- (nullable IMP)imp;

@end

NS_ASSUME_NONNULL_END
