//
//  DNInterfaceRegistry.m
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import "DNInterfaceRegistry.h"
#import <objc/message.h>
#import <os/lock.h>

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

// Map: Dart interface name -> OC class
static NSMutableDictionary<NSString *, Class> *interfaceNameToClassInnerMap;
static NSDictionary<NSString *, Class> *interfaceNameToClassCache;

// Map: Dart interface name -> OC meta data
static NSMutableDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *interfaceMethodsInnerMap;
static DartNativeInterfaceMap interfaceMethodsCache;

/// Register interface, called from +load method.
/// @param name The interface name for dart
/// @param cls The OC class that implements the interface
BOOL DartNativeRegisterInterface(NSString *name, Class cls) {
    if (!cls || name.length == 0) {
        return NO;
    }
        
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceNameToClassInnerMap = [NSMutableDictionary dictionary];
        interfaceMethodsInnerMap = [NSMutableDictionary dictionary];
    });

    if (interfaceNameToClassInnerMap[name]) {
        return NO;
    }
    interfaceNameToClassInnerMap[name] = cls;
    
    // find all registered methods
    NSMutableDictionary<NSString *, NSString *> *tempMethods = [NSMutableDictionary dictionary];
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
    interfaceMethodsInnerMap[name] = [tempMethods copy];
    return YES;
}

NSObject *DNInterfaceHostObjectWithName(NSString *name) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceNameToClassCache = [interfaceNameToClassInnerMap copy];
    });
    Class cls = interfaceNameToClassCache[name];
    SEL selector = NSSelectorFromString(@"sharedInstanceForDartNative");
    NSObject *interface = ((NSObject *(*)(Class, SEL))objc_msgSend)(cls, selector);
    return interface;
}

DartNativeInterfaceMap DNInterfaceAllMetaData(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interfaceMethodsCache = [interfaceMethodsInnerMap copy];
    });
    return interfaceMethodsCache;
}

