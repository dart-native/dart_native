//
//  DNBlockHelper.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/10/18.
//

#import "DNBlockHelper.h"
#import "DNDartBridge.h"

#if !__has_feature(objc_arc)
#error
#endif

@implementation DNBlockHelper

+ (void)invokeInterfaceBlock:(void *)block
                   arguments:(NSArray *)arguments
                      result:(BlockResultCallback)resultCallback {
    DNInterfaceBlockInvoke(block, arguments, resultCallback);
}

+ (BOOL)testNotifyDart:(int64_t)port {
    return TestNotifyDart(port);
}

@end
