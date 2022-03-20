//
//  DNInterfaceRegistry.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import "DNInterfaceRegistry.h"
#import <objc/message.h>
#import <os/lock.h>
#if __has_include(<ClassWrittenInSwift/ClassWrittenInSwift.h>)
#import <ClassWrittenInSwift/ClassWrittenInSwift.h>
#else
@import ClassWrittenInSwift;
#endif

#if !__has_feature(objc_arc)
#error
#endif

NSString *DNSelectorNameForMethodDeclaration(NSString *methodDeclaration) {
    if (![methodDeclaration containsString:@":"]) {
        return methodDeclaration;
    }
    NSMutableString *selectorName = [[NSMutableString alloc] init];
    NSArray *spaceSplit = [methodDeclaration componentsSeparatedByString:@" "];
    for (NSUInteger i = 0; i < spaceSplit.count; i++) {
        if (![spaceSplit[i] containsString:@":"]) {
            continue;
        }
        NSArray *colonSplit = [spaceSplit[i] componentsSeparatedByString:@":"];
        if (colonSplit.count == 2) {
            [selectorName appendFormat:@"%@:", colonSplit[0]];
        } else if (colonSplit.count == 1) {
            [selectorName appendString:@":"];
        }
    }
    return selectorName;
}

typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, id> *> *> *InterfaceMethodCallMap;

@interface DNInterfaceRegistry ()

@property (class, nonatomic, readonly) dispatch_queue_t methodCallBlockQueue;
@property (class, nonatomic, readonly) InterfaceMethodCallMap methodCallBlockInnerMap;
@property (class, nonatomic, readonly) NSDictionary<NSString *, NSString *> *interfaceClassToNameMap;

@end

@implementation DNInterfaceRegistry

#if Debug
static BOOL _exceptionEnabled = YES;
#else
static BOOL _exceptionEnabled = NO;
#endif

+ (BOOL)isExceptionEnabled {
    return _exceptionEnabled;
}

+ (void)setExceptionEnabled:(BOOL)exceptionEnabled {
    _exceptionEnabled = exceptionEnabled;
}

// Map: Dart interface name -> OC class
static NSMutableDictionary<NSString *, Class> *interfaceNameToClassInnerMap;
static NSDictionary<NSString *, Class> *interfaceNameToClassCache;

static NSMutableDictionary<NSString *, NSString *> *interfaceClassToNameInnerMap;
static NSDictionary<NSString *, NSString *> *_interfaceClassToNameMap;

+ (NSDictionary<NSString *, NSString *> *)interfaceClassToNameMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _interfaceClassToNameMap = [interfaceClassToNameInnerMap copy];
    });
    return _interfaceClassToNameMap;
}

// Map: Dart interface name -> OC meta data
static NSMutableDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *interfaceMethodsInnerMap;
static NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *interfaceMethodsCache;

+ (void)load {
    unsigned int countOfMethods = 0;
    Method *methods = class_copyMethodList(object_getClass(self), &countOfMethods);
    for (int i = 0; i < countOfMethods; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        const char *typeEncoding = method_getTypeEncoding(method);
        if (strcmp(typeEncoding, "#16@0:8") == 0) {
            Class cls = ((Class (*)(Class, SEL))method_getImplementation(method))(self, selector);
            if (class_conformsToProtocol(cls, @protocol(SwiftInterfaceEntry))) {
                [self registerInterface:NSStringFromSelector(selector) forClass:cls];
            }
        }
    }
}

+ (BOOL)registerInterface:(NSString *)name forClass:(Class)cls {
    if (!cls || name.length == 0) {
        return NO;
    }
        
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceNameToClassInnerMap = [NSMutableDictionary dictionary];
        interfaceMethodsInnerMap = [NSMutableDictionary dictionary];
        interfaceClassToNameInnerMap = [NSMutableDictionary dictionary];
    });

    if (interfaceNameToClassInnerMap[name]) {
        return NO;
    }
    
    interfaceNameToClassInnerMap[name] = cls;
    interfaceClassToNameInnerMap[NSStringFromClass(cls)] = name;
    
    BOOL isSwiftClass = [ClassWrittenInSwift isSwiftClass:cls];
    // find all registered methods
    NSMutableDictionary<NSString *, NSString *> *tempMethods = [NSMutableDictionary dictionary];
    
    if (isSwiftClass) {
        if ([cls respondsToSelector:@selector(mappingTableForInterfaceMethod)]) {
            NSDictionary<NSString *, id> *table = [cls mappingTableForInterfaceMethod];
            [table enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
                tempMethods[key] = [NSString stringWithFormat:@"%@", obj];
            }];
        }
    } else {
        unsigned int methodCount;
        Method *methods = class_copyMethodList(object_getClass(cls), &methodCount);
        for (unsigned int i = 0; i < methodCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            if ([NSStringFromSelector(selector) hasPrefix:@"dn_interface_method_"]) {
                IMP imp = method_getImplementation(method);
                NSArray<NSString *> *entries = ((NSArray<NSString *> *(*)(id, SEL))imp)(cls, selector);
                if (entries.count != 2) {
                    continue;
                }
                // TODO: check duplicated entries
                tempMethods[entries[0]] = DNSelectorNameForMethodDeclaration(entries[1]);
            }
        }
        free(methods);
    }
    interfaceMethodsInnerMap[name] = [tempMethods copy];
    return YES;
}

/// Each interface has an object on each thread
/// @param name name of interface
+ (NSObject *)hostObjectWithName:(NSString *)name {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceNameToClassCache = [interfaceNameToClassInnerMap copy];
    });
    static NSString * const DartNativeInterfaceNameTLSPrefix = @"__DartNativeInterfaceName__";
    // store host object using tls.
    NSString *key = [NSString stringWithFormat:@"%@%@", DartNativeInterfaceNameTLSPrefix, name];
    NSObject *result = NSThread.currentThread.threadDictionary[key];
    Class cls = interfaceNameToClassCache[name];
    if (!result) {
        result = [[cls alloc] init];
        NSThread.currentThread.threadDictionary[key] = result;
    }
    return result;
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)allMetaData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceMethodsCache = [interfaceMethodsInnerMap copy];
    });
    return interfaceMethodsCache;
}

// Map: Dart interface name -> OC class
static InterfaceMethodCallMap _methodCallBlockInnerMap;
static dispatch_queue_t _methodCallBlockQueue;

+ (dispatch_queue_t)methodCallBlockQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _methodCallBlockQueue = dispatch_queue_create("com.dartnative.interface", DISPATCH_QUEUE_CONCURRENT);
    });
    return _methodCallBlockQueue;
}

+ (InterfaceMethodCallMap)methodCallBlockInnerMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _methodCallBlockInnerMap = [NSMutableDictionary dictionary];
    });
    return _methodCallBlockInnerMap;
}

+ (void)registerDartInterface:(NSString *)interface
                       method:(NSString *)method
                        block:(id)block
                     dartPort:(int64_t)port {
    if (interface.length == 0 || method.length == 0) {
        NSCAssert(NO, @"interface and method shouldn't be empty!");
        return;
    }
    dispatch_barrier_async(self.methodCallBlockQueue, ^{
        __auto_type methodCallMap = self.methodCallBlockInnerMap[interface];
        if (!methodCallMap) {
            methodCallMap = [NSMutableDictionary dictionary];
            self.methodCallBlockInnerMap[interface] = methodCallMap;
        }
        __auto_type callForPortMap = methodCallMap[method];
        if (!callForPortMap) {
            callForPortMap = [NSMutableDictionary dictionary];
            methodCallMap[method] = callForPortMap;
        }
        callForPortMap[@(port)] = block;
    });
}

+ (void)invokeMethod:(NSString *)method
        forInterface:(NSString *)interface
           arguments:(NSArray *)arguments
              result:(DartNativeResult)result {
    if (interface.length == 0 || method.length == 0) {
        NSCAssert(NO, @"interface and method shouldn't be empty!");
        return;
    }
    extern BOOL TestNotifyDart(int64_t port_id);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        __block NSDictionary<NSNumber *, id> *callForPortMap;
        dispatch_sync(self.methodCallBlockQueue, ^{
            callForPortMap = [self.methodCallBlockInnerMap[interface][method] copy];
        });
        if (callForPortMap.count == 0) {
            NSCAssert(NO, @"Can't find method(%@) on interface(%@)!", method, interface);
        }
        Class target = NSClassFromString(@"DNBlockWrapper");
        SEL invokeInterfaceSel = NSSelectorFromString(@"invokeInterfaceBlock:arguments:result:");
        SEL testNotifyDartSel = NSSelectorFromString(@"testNotifyDart:");
        if (!target || !invokeInterfaceSel) {
            NSCAssert(NO, @"Can't load class DNBlockWrapper!");
            return;
        }
        [callForPortMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            int64_t port = key.longValue;
            // test isolate alive.
            BOOL success = ((BOOL(*)(Class, SEL, int64_t))objc_msgSend)(target, testNotifyDartSel, port);
            if (success) {
                ((void(*)(Class, SEL, void *, NSArray *, id))objc_msgSend)(target, invokeInterfaceSel, (__bridge void *)(obj), arguments, result);
            } else {
                // remove block for dead isolate.
                [self registerDartInterface:interface method:method block:nil dartPort:port];
            }
        }];
    });
}

@end

@implementation NSObject (DNInterface)

+ (void)invokeMethod:(NSString *)method
           arguments:(nullable NSArray *)arguments
              result:(nullable DartNativeResult)result {
    NSString *interfaceName = DNInterfaceRegistry.interfaceClassToNameMap[NSStringFromClass(self)];
    [DNInterfaceRegistry invokeMethod:method
                         forInterface:interfaceName
                            arguments:arguments
                               result:result];
}

- (void)invokeMethod:(NSString *)method
           arguments:(nullable NSArray *)arguments
              result:(nullable DartNativeResult)result {
    NSString *interfaceName = DNInterfaceRegistry.interfaceClassToNameMap[NSStringFromClass(self.class)];
    [DNInterfaceRegistry invokeMethod:method
                         forInterface:interfaceName
                            arguments:arguments
                               result:result];
}

@end
