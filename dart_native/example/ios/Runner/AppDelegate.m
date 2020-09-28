#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "RuntimeSon.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
