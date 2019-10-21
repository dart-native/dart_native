//
//  BlockCreator.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>

@class FlutterMethodChannel;

NS_ASSUME_NONNULL_BEGIN

@interface DOBlockWrapper : NSObject

@property (nonatomic, readonly) id block;

- (instancetype)initWithTypeString:(char *)typeString;

@end

NS_ASSUME_NONNULL_END
