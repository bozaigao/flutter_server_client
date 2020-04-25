#import <Flutter/Flutter.h>

#import "AppDelegate.h"
@interface FlutterNimPlugin : NSObject<FlutterPlugin,NIMChatManagerDelegate>
- (void) registerFlutterNimPlugin;
+ (void) registerWithRegistrar;
@property FlutterMethodChannel * channel;
@end
