//
//  DNInterfaceRegistry.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import <Foundation/Foundation.h>

#define InterfaceEntry(name)                                          \
    class DNInterfaceRegistry;                                        \
    + (void)load {                                                    \
        [DNInterfaceRegistry registerInterface:@#name forClass:self]; \
    }

#define InterfaceMethod(name, method)                       \
    class DNInterfaceRegistry;                              \
    DN_REGISTER_METHOD(name, method, __LINE__, __COUNTER__)

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
