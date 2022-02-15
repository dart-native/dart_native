//
//  DartNativeInterface.h
//  dart_native
//
//  Created by 杨萧玉 on 2022/2/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DartNativeResult)(id _Nullable result);
typedef void (^DartNativeFunction)(id _Nullable arguments, ...);

@interface DartNativeInterface : NSObject

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;
- (void)invokeMethod:(NSString*)method
              result:(DartNativeResult _Nullable)callback
           arguments:(id _Nullable)arguments, ...;

@end

NS_ASSUME_NONNULL_END
