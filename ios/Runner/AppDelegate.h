#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <NIMSDK/NIMSDK.h>
#import "NTESCustomAttachmentDecoder.h"
#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface AppDelegate : FlutterAppDelegate

@end
