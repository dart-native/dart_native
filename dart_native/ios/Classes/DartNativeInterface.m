//
//  DartNativeInterface.m
//  dart_native
//
//  Created by 杨萧玉 on 2022/2/14.
//

#import "DartNativeInterface.h"
#import <DartNative/native_runtime.h>

@interface DartNativeInterface ()

@property (nonatomic, readwrite) NSString *name;

@end

@implementation DartNativeInterface

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (void)invokeMethod:(NSString*)method
              result:(DartNativeResult _Nullable)callback
           arguments:(id _Nullable)arguments, ... {
    DartNativeFunction function = (DartNativeFunction)^void(NSString *b, NSString *a) {
        
    };
    va_list args;
    va_start(args, arguments);
//    function(arguments, args);
    va_end(args);
}

@end
