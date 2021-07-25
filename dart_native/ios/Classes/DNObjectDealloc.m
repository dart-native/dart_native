//
//  DNObjectDealloc.m
//  DartNative
//
//  Created by 杨萧玉 on 2019/11/5.
//

#import "DNObjectDealloc.h"
#import "native_runtime.h"

@interface DNObjectDealloc ()

@property (nonatomic, readonly) intptr_t hostAddress;

@end

@implementation DNObjectDealloc

static const void *DNObjectDeallocStorageKey = (void *)&DNObjectDeallocStorageKey;

- (instancetype)initWithHost:(NSObject *)host
                  storageKey:(nonnull const void *)storageKey {
    self = [super initWithHost:host storageKey:storageKey];
    if (self) {
        _hostAddress = (intptr_t)host;
    }
    return self;
}

+ (instancetype)objectForHost:(NSObject *)host {
    return [super objectForHost:host storageKey:DNObjectDeallocStorageKey];
}

+ (nullable instancetype)attachHost:(NSObject *)host
                           dartPort:(Dart_Port)dartPort {
    DNObjectDealloc *dealloc = [super attachHost:host
                                        dartPort:dartPort
                                      storageKey:DNObjectDeallocStorageKey];
    return dealloc;
}

- (void)dealloc {
    NSSet<NSNumber *> *dartPorts = self.dartPorts;
    for (NSNumber *dartPort in dartPorts) {
        NotifyDeallocToDart(_hostAddress, dartPort.integerValue);
    }
}

@end
