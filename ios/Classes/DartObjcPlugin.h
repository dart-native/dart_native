#import <Flutter/Flutter.h>

@interface DartObjcPlugin : NSObject<FlutterPlugin>

@property (nonatomic, class) FlutterMethodChannel *channel;

@end
