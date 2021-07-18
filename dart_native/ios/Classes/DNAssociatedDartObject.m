//
//  DNDartPortsContainer.m
//  dart_native
//
//  Created by 杨萧玉 on 2021/7/18.
//

#import "DNAssociatedDartObject.h"
#import <objc/runtime.h>
#import "native_runtime.h"

@interface DNAssociatedDartObject ()

@property (nonatomic) NSMutableSet<NSNumber *> *internalDartPorts;
@property (nonatomic) dispatch_queue_t portsQueue;

@end

@implementation DNAssociatedDartObject

- (instancetype)initWithHost:(NSObject *)host
                  storageKey:(nonnull const void *)storageKey {
    self = [super init];
    if (self) {
        _host = host;
        _internalDartPorts = [NSMutableSet set];
        _portsQueue = dispatch_queue_create("com.dartnative.associatedobject", DISPATCH_QUEUE_CONCURRENT);
        objc_setAssociatedObject(host, storageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

+ (instancetype)attachHost:(NSObject *)host
                  dartPort:(Dart_Port)dartPort
                storageKey:(nonnull const void *)storageKey {
    if (!host) {
        return nil;
    }
    __kindof DNAssociatedDartObject *object = [self objectForHost:host
                                                       storageKey:storageKey];
    if (!object && (!objc_isTaggedPointer((__bridge const void *)(host)) ||
               [host isKindOfClass:NSClassFromString(@"__NSMallocBlock")])) {
        object = [[self alloc] initWithHost:host storageKey:storageKey];
    }
    [object addDartPort:dartPort];
    return object;
}

+ (instancetype)objectForHost:(NSObject *)host
                   storageKey:(nonnull const void *)storageKey {
    return objc_getAssociatedObject(host, storageKey);
}

- (NSSet<NSNumber *> *)dartPorts {
    __block NSSet<NSNumber *> *temp;
    dispatch_sync(self.portsQueue, ^{
        temp = [self.internalDartPorts copy];
    });
    return temp;
}

- (void)addDartPort:(Dart_Port)port {
    dispatch_barrier_async(self.portsQueue, ^{
        [self.internalDartPorts addObject:@(port)];
    });
}

- (void)removeDartPort:(Dart_Port)port {
    dispatch_barrier_async(self.portsQueue, ^{
        [self.internalDartPorts removeObject:@(port)];
    });
}

@end
