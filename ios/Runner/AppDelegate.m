#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import "FlutterNimPlugin.h"
#import "NativeUtilPlugin.h"
#import <PushKit/PushKit.h>
#import "UIView+Toast.h"
#import "FlutterSoundPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureFlutterEngine];
    //网易云信sdk初始化
    NSString *appKey        = @"应用密钥";
      NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
      option.apnsCername      = @"网易云后台推送证书名字";
        [[NIMSDK sharedSDK] registerWithOption:option];
    [self registerPushService];
    //注册自定义消息的解析器
    [NIMCustomObject registerCustomDecoder:[NTESCustomAttachmentDecoder new]];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

//注册加密模块
- (void) configureFlutterEngine{
    //网易云信聊天模块
      [FlutterNimPlugin registerWithRegistrar:[self registrarForPlugin:@"www.guigug.com/flutter_nim_plugin"]];
    [NativeUtilPlugin registerWithRegistrar:[self registrarForPlugin:@"www.guigug.com/native_util_plugin"]];
    //录音与播放
     [FlutterSoundPlugin registerWithRegistrar:[self registrarForPlugin:@"www.guigug.com/flutter_soundv"]];
}

-(void)applicationProtectedDataWillBecomeUnavailable:(NSNotificationCenter *)notification{
  NSLog(@"锁屏");
}

- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *) notification{
  NSLog(@"解锁");
  [[NSNotificationCenter defaultCenter]postNotificationName:@"screenLockChange" object: nil];
}

#pragma mark - misc
- (void)registerPushService
{
    if (@available(iOS 11.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted)
            {
                dispatch_async_main_safe(^{
                    [[UIApplication sharedApplication].keyWindow makeToast:@"请开启推送功能否则无法收到推送通知" duration:2.0 position:CSToastPositionCenter];
                })
            }
        }];
    }
    else
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    //pushkit
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    // 注册push权限，用于显示本地推送
      [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
}


#pragma mark PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type
{
    if ([type isEqualToString:PKPushTypeVoIP])
    {
        [[NIMSDK sharedSDK] updatePushKitToken:credentials.token];
    }
}

// 网易云信聊天消息推送配置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  NSLog(@"正在注册推送");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  
  NSLog(@"网易云信推送deviceToken%@",deviceToken);
  [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}


// Required for the registrationError event.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  
    NSLog(@"推送注册失败%@",error.localizedDescription);
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"receive payload %@ type %@", payload.dictionaryPayload,type);
    NSNumber *badge = payload.dictionaryPayload[@"aps"][@"badge"];
    if ([badge isKindOfClass:[NSNumber class]])
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber = [badge integerValue];
    }
}



- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type
{
    NSLog(@"registry %@ invalidate %@",registry,type);
}
@end
