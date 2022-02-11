//
//  DNInterfaceRegistry.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import <Foundation/Foundation.h>

#define DN_INTERFACE_ENTRY(name)                                               \
    + (void)load {                                                             \
        [DNInterfaceRegistry registerInterface:@#name forClass:self];          \
    }

#define DN_INTERFACE_METHOD(name, method) DN_REGISTER_METHOD(name, method, __LINE__, __COUNTER__)

#define DN_REGISTER_METHOD(name, method, line, count) \
    DN_EXPORT_METHOD(name, method, line, count)       \
    - (id)method

#define DN_EXPORT_METHOD(name, method, line, count)                    \
    + (NSArray<NSString *> *)dn_interface_method_##name##line##count { \
        return @[@#name, @#method];                                    \
    }

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(InterfaceRegistry)
@interface DNInterfaceRegistry : NSObject

/// Register interface, called from +load method.
/// @param name The interface name for dart
/// @param cls The OC class that implements the interface
+ (BOOL)registerInterface:(NSString *)name forClass:(Class)cls;

@end

@protocol SwiftInterfaceEntry

@required
- (NSDictionary<NSString *, id> *)mappingTableForInterfaceMethod;

@end

NS_ASSUME_NONNULL_END
