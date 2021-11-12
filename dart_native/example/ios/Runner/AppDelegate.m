#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#if __has_include(<CocoaLumberjack/CocoaLumberjack.h>)
#import <CocoaLumberjack/CocoaLumberjack.h>
#else
@import CocoaLumberjack;
#endif

#if __has_include(<dart_native/native_runtime.h>)
#import <dart_native/native_runtime.h>
#else
@import dart_native;
#endif

#import "RuntimeSon.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    void DartNativeSetThrowException(bool canThrow);
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
        if ([call.method isEqualToString:@"fooString"]) {
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
