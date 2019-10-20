#import "DartObjcPlugin.h"

@implementation DartObjcPlugin

static FlutterMethodChannel *_channel;

+ (FlutterMethodChannel *)channel
{
    return _channel;
}

+ (void)setChannel:(FlutterMethodChannel *)channel
{
    _channel = channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self.channel = [FlutterMethodChannel
      methodChannelWithName:@"dart_objc"
            binaryMessenger:[registrar messenger]];
  DartObjcPlugin *instance = [[DartObjcPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:self.channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
