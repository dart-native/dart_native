//
//  RuntimeStub.h
//  native_runtime
//
//  Created by 杨萧玉 on 2019/9/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, TestOptions) {
    TestOptionsNone = 0,
    TestOptionsOne = 1 << 0,
    TestOptionsTwo = 1 << 1,
};

@interface RuntimeStub : NSObject

@end

NS_ASSUME_NONNULL_END
