//
//  DNMethodIMP.h
//  dart_native
//
//  Created by 杨萧玉 on 2019/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNMethodIMP : NSObject

- (instancetype)initWithTypeEncoding:(const char *)typeEncodings callback:(void *)callback;
- (IMP)imp;

@end

NS_ASSUME_NONNULL_END
