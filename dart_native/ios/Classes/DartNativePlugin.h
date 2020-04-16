#import <Flutter/Flutter.h>

@interface DartNativePlugin : NSObject<FlutterPlugin>

@property (nonatomic, class) FlutterMethodChannel *channel;

@end
