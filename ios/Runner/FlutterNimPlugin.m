#import "FlutterNimPlugin.h"
#import "NimMessageHelper.h"
@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
    return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                               message:self.domain
                               details:self.localizedDescription];
}
@end

@implementation FlutterNimPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"www.guigug.com/flutter_nim_plugin"
                                     binaryMessenger:[registrar messenger]];
    FlutterNimPlugin* instance = [[FlutterNimPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"nimLogin" isEqualToString:call.method]) {
        [self nimLogin:call result:result];
    }else if ([@"loginOut" isEqualToString:call.method]) {
        [self loginOut:call result:result];
    }else if ([@"getUserInfo" isEqualToString:call.method]) {
        [self getUserInfo:call result:result];
    }else if ([@"getHistoryMessages" isEqualToString:call.method]) {
        [self getHistoryMessages:call result:result];
    }else if ([@"sendMessage" isEqualToString:call.method]) {
        [self sendMessage:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}



- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages{
    NSLog(@"收到消息了");
    NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      NIMMessage *message = obj;
      return [message messageToDictionary];
    }];
    
    [_channel invokeMethod:@"onReceiveMessage" arguments: messageDicArr];
}

/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 登录网易云信
 */
- (void)nimLogin:(FlutterMethodCall*)call result:(FlutterResult)result {
     [[NIMSDK sharedSDK].chatManager addDelegate:self];
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString *token = @"";
    if (param[@"account"]) {
        account = param[@"account"];
    }
    if (param[@"token"]) {
        token = param[@"token"];
    }
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
        if(error){
            result([error flutterError]);
        }else{
            NSLog(@"登录成功");
            result(nil);
        }
    }];
}


/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 登出
 */
- (void)loginOut:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        if(error){
            result([error flutterError]);
        }else{
            result(nil);
        }
    }];
}


/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 获取用户信息
 */
- (void)getUserInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSString *account = param[@"account"];
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:account];
    result([user userToDictionary]);
}


/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 获取历史消息
 */
- (void)getHistoryMessages:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSString *sessionId = @"";
    NSString *uuid = @"";
    if(param[@"uuid"]){
        uuid = param[@"uuid"];
    }
    if(param[@"sessionId"]){
        sessionId = param[@"sessionId"];
    }
    
    NSArray<NSString *> *uuids = [[NSArray alloc]initWithObjects:uuid, nil];
    NIMSession * nimSession = [NIMSession session:sessionId type:NIMSessionTypeP2P];
    NSArray<NIMMessage *> * messages = [[NIMSDK sharedSDK].conversationManager messagesInSession: nimSession messageIds:uuids];
    
    NSArray<NIMMessage *> * messageList = [[NIMSDK sharedSDK].conversationManager messagesInSession:nimSession message:messages[0] limit:20];
    NSArray *messageDicArr = [messageList mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
      NIMMessage *message = obj;
      return [message messageToDictionary];
    }];
    
    result(messageDicArr);
}

/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 发送文本、图片、音频消息
 */
- (void)sendMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString * type = @"";
    NSString * messageFlag = @"";
    if(param[@"account"]){
        account = param[@"account"];
    }
    if(param[@"type"]){
        type = param[@"type"];
    }
    if(param[@"messageFlag"]){
        messageFlag = param[@"messageFlag"];
    }
    // 构造出具体会话
    NIMSession *session = [NIMSession session:account type:NIMSessionTypeP2P];
    // 构造出具体消息
    NIMMessage *message = [[NIMMessage alloc] init];
    message.localExt = @{@"messageFlag":messageFlag};
    if([type isEqualToString:@"NIMMessageTypeText"]){
        if(param[@"message"]){
             message.text        = param[@"message"];
        }
    }else if([type isEqualToString:@"NIMMessageTypeImage"] ){
        if(param[@"message"]){
            // 获得图片附件对象
             NIMImageObject *object = [[NIMImageObject alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:param[@"message"]]]];
            message.messageObject = object;
        }
    }else if([type isEqualToString:@"NIMMessageTypeAudio"]){
       if(param[@"message"]){
             // 获得语音附件对象
                   NIMAudioObject *audioObject = [[NIMAudioObject alloc] initWithData:[NSData dataWithContentsOfFile:param[@"message"]] extension:@"aac"];
                   message.messageObject = audioObject;
        }
    }
    // 错误反馈对象
    NSError *error = nil;
    // 发送消息
    BOOL sendState = [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];
    
    if(sendState){
        result([message messageToDictionary]);
    }else{
        result(nil);
    }
    
    
}
@end
