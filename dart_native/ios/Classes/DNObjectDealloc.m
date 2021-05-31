//
//  DNObjectDealloc.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNObjectDealloc.h"
#import <objc/runtime.h>
#import "native_runtime.h"

#if !__has_feature(objc_arc)
#error
#endif

#if TARGET_OS_OSX && __x86_64__
    // 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
    // Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1UL<<63)
#else
#   define _OBJC_TAG_MASK 1UL
#endif

static inline bool
_objc_isTaggedPointer(const void *ptr) {
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

@interface DNObjectDealloc ()

@property (nonatomic, readonly, weak) NSObject *host;
@property (nonatomic, readonly) int64_t hostAddress;
@property (nonatomic, readonly) Dart_Port dartPort;

@end

@implementation DNObjectDealloc

+ (void)attachHost:(NSObject *)host
          dartPort:(Dart_Port)dartPort {
    if (!host || objc_getAssociatedObject(host, @selector(initWithHost:dartPort:))) {
        return;
    }
    if (!_objc_isTaggedPointer((__bridge const void *)(host)) ||
        [host isKindOfClass:NSClassFromString(@"__NSMallocBlock")]) {
        __unused DNObjectDealloc *dealloc = [[self alloc] initWithHost:host
                                                              dartPort:dartPort];
    }
}

static int64_t fuxk;

- (instancetype)initWithHost:(NSObject *)host
                    dartPort:(Dart_Port)dartPort {
    self = [super init];
    if (self) {
        _host = host;
        _hostAddress = (int64_t)host;
//        if ([host isKindOfClass:NSClassFromString(@"Fuck")]) {
//            fuxk = _hostAddress;
//        }
        _dartPort = dartPort;
        objc_setAssociatedObject(host, _cmd, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (void)dealloc {
//    if (_hostAddress == fuxk) {
//        
//    }
    NotifyDeallocToDart(_hostAddress, _dartPort);
}

@end
