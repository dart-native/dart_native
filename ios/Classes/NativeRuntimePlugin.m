#import "NativeRuntimePlugin.h"
#import <native_runtime/native_runtime-Swift.h>

@implementation NativeRuntimePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeRuntimePlugin registerWithRegistrar:registrar];
}
@end
