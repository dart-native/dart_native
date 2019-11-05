//
//  DOObjectDealloc.m
//  dart_objc
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DOObjectDealloc.h"
#import <objc/runtime.h>
#import "DartObjcPlugin.h"

#if TARGET_OS_OSX && __x86_64__
    // 64-bit Mac - tag bit is LSB
#   define OBJC_MSB_TAGGED_POINTERS 0
#else
    // Everything else - tag bit is MSB
#   define OBJC_MSB_TAGGED_POINTERS 1
#endif

#if OBJC_MSB_TAGGED_POINTERS
#   define _OBJC_TAG_MASK (1ULL<<63)
#else
#   define _OBJC_TAG_MASK 1
#endif

static inline bool
_objc_isTaggedPointer(const void *ptr)
{
    return ((intptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

@interface DOObjectDealloc ()

@property (nonatomic, weak) NSObject *host;
@property (nonatomic) int64_t hostAddress;

@end

@implementation DOObjectDealloc

+ (void)attachHost:(NSObject *)host
{
    if (!_objc_isTaggedPointer((__bridge const void *)(host)) || [host isKindOfClass:NSClassFromString(@"__NSMallocBlock")]) {
        __unused DOObjectDealloc *dealloc = [[self alloc] initWithHost:host];
    }
}

- (instancetype)initWithHost:(NSObject *)host
{
    self = [super init];
    if (self) {
        _host = host;
        _hostAddress = (int64_t)host;
        objc_setAssociatedObject(host, _cmd, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (void)dealloc
{
    // TODO: replace with ffi callback.
    [DartObjcPlugin.channel invokeMethod:@"object_dealloc" arguments:@[@(_hostAddress)]];
}

@end
