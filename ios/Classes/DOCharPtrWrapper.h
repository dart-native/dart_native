//
//  DOCharPtrWrapper.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DOCharPtrWrapper : NSObject

- (void)setCString:(const char *)cString;

@end

NS_ASSUME_NONNULL_END
