//
//  DNMethod.h
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>
#import "dart_api_dl.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (*DartImplemetion)(void *_Nullable *_Null_unspecified args,
                                    void *ret,
                                    int numberOfArguments,
                                    const char *_Nonnull *_Nonnull types,
                                    BOOL stret);

@interface DNMethod : NSObject

@property (nonatomic, getter=hasStret, readonly) BOOL stret;
@property (nonatomic, getter=isReturnString, readonly) BOOL returnString;
// Every dart port has its own callback.
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSNumber *> *callbackForDartPort;

- (instancetype)initWithTypeEncoding:(const char *)typeEncodings
                       dartImpletion:(DartImplemetion)dartImpletion
                        returnString:(BOOL)returnString
                            dartPort:(Dart_Port)dartPort
                               error:(NSError **)error;
- (void)addDartImplementation:(DartImplemetion)imp forPort:(Dart_Port)port;
- (void)removeDartImplemetionForPort:(Dart_Port)port;
- (nullable IMP)objcIMP;

@end

NS_ASSUME_NONNULL_END
