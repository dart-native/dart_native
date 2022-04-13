#import "DartNativePlugin.h"

@implementation DartNativePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dart_native"
            binaryMessenger:[registrar messenger]];
  DartNativePlugin* instance = [[DartNativePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
#if TARGET_OS_OSX
      result([@"macOS " stringByAppendingString:NSProcessInfo.processInfo.operatingSystemVersionString]);
#elif TARGET_OS_IOS
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
#endif
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
