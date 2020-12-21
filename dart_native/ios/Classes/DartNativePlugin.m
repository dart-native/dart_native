#import "DartNativePlugin.h"

@implementation DartNativePlugin

static FlutterMethodChannel *_channel;

+ (FlutterMethodChannel *)channel {
    return _channel;
}

+ (void)setChannel:(FlutterMethodChannel *)channel {
    _channel = channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    _channel = [FlutterMethodChannel methodChannelWithName:@"dart_native"
                                         binaryMessenger:[registrar messenger]];
    DartNativePlugin *instance = [[DartNativePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:_channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
