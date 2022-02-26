//
//  DNInterfaceRegistry.h
//  DartNative
//
//  Created by 杨萧玉 on 2022/2/6.
//

#import <Foundation/Foundation.h>

#define InterfaceEntry(name)                                          \
    + (void)load {                                                    \
        [DNInterfaceRegistry registerInterface:@#name forClass:self]; \
    }                                                                 \

#define InterfaceMethod(name, method) \
    RegisterMethod(name, method, __LINE__, __COUNTER__)

#define RegisterMethod(name, method, line, count) \
    ExportMethod(name, method, line, count)       \
    - (id)method

#define ExportMethod(name, method, line, count)                        \
    + (NSArray<NSString *> *)dn_interface_method_##name##line##count { \
        return @[@#name, @#method];                                    \
    }

NS_ASSUME_NONNULL_BEGIN

typedef void (^DartNativeResult)(id _Nullable result, NSError * _Nullable error);

NS_SWIFT_NAME(InterfaceRegistry)
@interface DNInterfaceRegistry : NSObject

/// Register interface, called from +load method.
/// @param name The interface name for dart
/// @param cls The OC class that implements the interface
+ (BOOL)registerInterface:(NSString *)name forClass:(Class)cls;
+ (void)registerDartInterface:(NSString *)interface
                       method:(NSString *)method
                        block:(nullable id)block
                     dartPort:(int64_t)port;
+ (void)invokeMethod:(NSString *)method
        forInterface:(NSString *)interface
           arguments:(nullable NSArray *)arguments
              result:(nullable DartNativeResult)result;

@end

@protocol SwiftInterfaceEntry

@required

+ (NSDictionary<NSString *, id> *)mappingTableForInterfaceMethod;

@end

@interface NSObject (DNInterface)

+ (void)invokeMethod:(NSString *)method
           arguments:(nullable NSArray *)arguments
              result:(nullable DartNativeResult)result;

- (void)invokeMethod:(NSString *)method
           arguments:(nullable NSArray *)arguments
              result:(nullable DartNativeResult)result;

@end

NS_ASSUME_NONNULL_END
