//
//  DNObjectDealloc.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNObjectDealloc.h"
#import <objc/runtime.h>
#import "native_runtime.h"

@interface DNObjectDealloc ()

@property (nonatomic, readonly, weak) NSObject *host;
@property (nonatomic, readonly) intptr_t hostAddress;
@property (nonatomic, readonly) Dart_Port dartPort;

@end

@implementation DNObjectDealloc

+ (void)attachHost:(NSObject *)host
          dartPort:(Dart_Port)dartPort {
    if (!host || objc_getAssociatedObject(host, @selector(initWithHost:dartPort:))) {
        return;
    }
    if (!objc_isTaggedPointer((__bridge const void *)(host)) ||
        [host isKindOfClass:NSClassFromString(@"__NSMallocBlock")]) {
        __unused DNObjectDealloc *dealloc = [[self alloc] initWithHost:host
                                                              dartPort:dartPort];
    }
}

- (instancetype)initWithHost:(NSObject *)host
                    dartPort:(Dart_Port)dartPort {
    self = [super init];
    if (self) {
        _host = host;
        _hostAddress = (intptr_t)host;
        _dartPort = dartPort;
        objc_setAssociatedObject(host, _cmd, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (void)dealloc {
    NotifyDeallocToDart(_hostAddress, _dartPort);
}

@end
