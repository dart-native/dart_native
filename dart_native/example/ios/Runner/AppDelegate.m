#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

#if __has_include(<dart_native/dart_native.h>)
#import <dart_native/dart_native.h>
#else
@import dart_native;
#endif

#import "RuntimeSon.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    DartNativeSetThrowException(true);
#else
    DartNativeSetThrowException(false);
#endif
    FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;

    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"sample.dartnative.com"
                                                                       binaryMessenger:controller.binaryMessenger];
    RuntimeSon *son = [RuntimeSon new];
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([call.method isEqualToString:@"fooNSString:"]) {
            result([son fooNSString:call.arguments]);
        }
    }];
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    [DDLog addLogger:[DDOSLogger sharedInstance]]; // Uses os_log

    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
