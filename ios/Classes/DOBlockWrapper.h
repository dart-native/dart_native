//
//  DOBlockWrapper.h
//  dart_objc
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import "DOMacro.h"

NS_ASSUME_NONNULL_BEGIN

DO_EXTERN
const char *DOBlockTypeEncodeString(id blockObj);

@interface DOBlockWrapper : NSObject

@property (nonatomic, readonly) id block;

- (instancetype)initWithTypeString:(char *)typeString callback:(void *)callback;;

@end

NS_ASSUME_NONNULL_END
