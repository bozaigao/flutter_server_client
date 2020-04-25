#import <Flutter/Flutter.h>
#import <NIMSDK/NIMSDK.h>
#import "AppDelegate.h"
@interface FlutterNimPlugin : NSObject<FlutterPlugin,NIMChatManagerDelegate,NIMConversationManagerDelegate,
NIMLoginManagerDelegate>
+ (void) registerWithRegistrar;
@property FlutterMethodChannel * channel;
@property NSArray<NIMRecentSession *> * sessions;
@property NIMMessage * message;
@end
