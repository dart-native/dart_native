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

@implementation DNInterfaceRegistry

// Map: Dart interface name -> OC class
static NSMutableDictionary<NSString *, NSObject *> *interfaceNameToHostObjectInnerMap;
static NSDictionary<NSString *, NSObject *> *interfaceNameToHostObjectCache;

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
        interfaceNameToHostObjectInnerMap = [NSMutableDictionary dictionary];
        interfaceMethodsInnerMap = [NSMutableDictionary dictionary];
    });

    if (interfaceNameToHostObjectInnerMap[name]) {
        return NO;
    }
    NSObject<SwiftInterfaceEntry> *instance = [[cls alloc] init];
    interfaceNameToHostObjectInnerMap[name] = instance;
    
    BOOL isSwiftClass = [ClassWrittenInSwift isSwiftClass:cls];
    // find all registered methods
    NSMutableDictionary<NSString *, NSString *> *tempMethods = [NSMutableDictionary dictionary];
    
    if (isSwiftClass) {
        if ([instance respondsToSelector:@selector(mappingTableForInterfaceMethod)]) {
            NSDictionary<NSString *, id> *table = [instance mappingTableForInterfaceMethod];
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

+ (NSObject *)hostObjectWithName:(NSString *)name {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceNameToHostObjectCache = [interfaceNameToHostObjectInnerMap copy];
    });
    return interfaceNameToHostObjectCache[name];
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)allMetaData {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceMethodsCache = [interfaceMethodsInnerMap copy];
    });
    return interfaceMethodsCache;
}

@end
