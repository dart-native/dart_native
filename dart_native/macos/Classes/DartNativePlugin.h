#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#import <FlutterMacOS/FlutterMacOS.h>
#elif TARGET_OS_IOS
#import <Flutter/Flutter.h>
#endif


@interface DartNativePlugin : NSObject<FlutterPlugin>
@end
