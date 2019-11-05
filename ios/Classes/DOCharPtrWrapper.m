//
//  DOCharPtrWrapper.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DOCharPtrWrapper.h"

@interface DOCharPtrWrapper ()
{
    const char *_cString;
}
@end

@implementation DOCharPtrWrapper

- (void)setCString:(const char *)cString
{
    _cString = cString;
}

- (void)dealloc
{
    free((void *)_cString);
}

@end
