#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
