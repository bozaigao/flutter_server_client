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
    }else if ([@"sendMessage" isEqualToString:call.method]) {
        [self sendMessage:call result:result];
    }else if ([@"getAllSessions" isEqualToString:call.method]) {
        [self getAllSessions:call result:result];
    }else if ([@"getUsersInfo" isEqualToString:call.method]) {
        [self getUsersInfo:call result:result];
    }else if ([@"fetchMessageHistory" isEqualToString:call.method]) {
        [self fetchMessageHistory:call result:result];
    }else if ([@"fetchLocalMessageHistory" isEqualToString:call.method]) {
        [self fetchLocalMessageHistory:call result:result];
    }else if ([@"resetMessage" isEqualToString:call.method]) {
        [self resetMessage:call result:result];
    }else if ([@"markAllMessagesReadInSession" isEqualToString:call.method]) {
        [self markAllMessagesReadInSession:call result:result];
    }else if ([@"markAllMessagesRead" isEqualToString:call.method]) {
        [self markAllMessagesRead:call result:result];
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
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    NSDictionary *param = call.arguments;
    NSString *account = @"";
    NSString *token = @"";
    if (param[@"account"]) {
        account = param[@"account"];
    }
    if (param[@"token"]) {
        token = param[@"token"];
    }
    
    NSLog(@"登录中%@,%@",account,token);
    
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
 * @desc: 设置所有会话已读
 */
- (void)markAllMessagesRead:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[[NIMSDK sharedSDK] conversationManager] markAllMessagesRead];
    //在这个方法里输入如下清除方法
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; //清除角标
    [[UIApplication sharedApplication] cancelAllLocalNotifications];//清除APP所有通知消息
}

/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 设置会话已读
 */
- (void)markAllMessagesReadInSession:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NIMRecentSession* session = nil;
    for(int i = 0;i<_sessions.count; i++){
        if([_sessions[i].session.sessionId isEqualToString:param[@"sessionId"]]){
            session =_sessions[i];
            break;
        }
    }
    [[[NIMSDK sharedSDK] conversationManager] markAllMessagesReadInSession:session.session];
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
 * @desc: 获取本地历史聊天数据
 */
- (void)fetchLocalMessageHistory:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    
    NIMSession* session = [NIMSession  session:param[@"sessionId"] type:NIMSessionTypeP2P];
    
    NIMHistoryMessageSearchOption* option = [[NIMHistoryMessageSearchOption alloc]init];
    
    option.limit = [param[@"limit"] integerValue];
    option.endTime = _message.timestamp;
    option.order = NIMMessageSearchOrderDesc;
    option.currentMessage = _message;
    NSArray<NIMMessage *> * messages = [[[NIMSDK sharedSDK] conversationManager] messagesInSession:session message:nil limit:[param[@"limit"] integerValue]];
    _message = messages[messages.count-1];
    NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NIMMessage *message = obj;
        return [message messageToDictionary];
    }];
    result(messageDicArr);
}



/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 获取云端历史聊天数据
 */
- (void)fetchMessageHistory:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    
    NIMSession* session = [NIMSession  session:param[@"sessionId"] type:NIMSessionTypeP2P];
    
    NIMHistoryMessageSearchOption* option = [[NIMHistoryMessageSearchOption alloc]init];
    
    option.limit = [param[@"limit"] integerValue];
    option.endTime = _message.timestamp;
    option.order = NIMMessageSearchOrderDesc;
    option.currentMessage = _message;
    [[[NIMSDK sharedSDK] conversationManager] fetchMessageHistory:session option:option result:^(NSError * _Nullable error, NSArray<NIMMessage *> * _Nullable messages) {
        if(error){
            result([error flutterError]);
        }else{
            if(messages.count>0){
                self.message = messages[messages.count -1];
                NSArray *messageDicArr = [messages mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                    NIMMessage *message = obj;
                    return [message messageToDictionary];
                }];
                result(messageDicArr);
            }else{
                result(@[]);
            }
            
        }
    }];
}

/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 重置message
 */
- (void)resetMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
    _message = nil;
    NSLog(@"重置message");
}



/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 获取所有的会话列表
 */
- (void)getAllSessions:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray<NIMRecentSession *>* allRecentSessions = [[[NIMSDK sharedSDK] conversationManager] allRecentSessions];
    _sessions = allRecentSessions;
    NSArray *recentSessionsDicArr = [allRecentSessions mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
        NIMRecentSession *session = obj;
        return [session recentSessionToDictionary];
    }];
    
    result(recentSessionsDicArr);
    
}


/**
 * @author 何晏波
 * @QQ 1054539528
 * @date 2020-02-08
 * @desc: 获取所有的会话用户资料
 */
- (void)getUsersInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *param = call.arguments;
    NSArray<NSString *>* userIds = param[@"userIds"];
    
    [[[NIMSDK sharedSDK] userManager] fetchUserInfos:userIds completion:^(NSArray<NIMUser *> * __nullable users,NSError * __nullable error){
        if(error == nil){
            NSArray *usersInfoDicArr = [users mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
                NIMUser *userInfo = obj;
                return [userInfo userToDictionary];
            }];
            result(usersInfoDicArr);
            
        }else{
            NSLog(@"%@",error.localizedDescription);
            result(@[]);
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
        if(param[@"path"]){
            // 获得图片附件对象
            NIMImageObject *object = [[NIMImageObject alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:param[@"path"]]]];
            message.messageObject = object;
            
        }
    }else if([type isEqualToString:@"NIMMessageTypeAudio"]){
        if(param[@"path"]){
            NSString * path = param[@"path"];
            if([path containsString:@"file://"]){
                path = [path substringFromIndex:7];
            }
            // 获得语音附件对象
            NIMAudioObject *audioObject = [[NIMAudioObject alloc] initWithData:[NSData dataWithContentsOfFile:path] extension:@"aac"];
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

/**
 *  增加最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 当新增一条消息，并且本地不存在该消息所属的会话时，会触发此回调。
 */
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    NSLog(@"didAddRecentSession");
    [_channel invokeMethod:@"onSessionUpdate" arguments: nil];
}



/**
 *  最近会话修改的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 *  @discussion 触发条件包括: 1.当新增一条消息，并且本地存在该消息所属的会话。
 *                          2.所属会话的未读清零。
 *                          3.所属会话的最后一条消息的内容发送变化。(例如成功发送后，修正发送时间为服务器时间)
 *                          4.删除消息，并且删除的消息为当前会话的最后一条消息。
 */
- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    NSLog(@"didUpdateRecentSession");
    [_channel invokeMethod:@"onSessionUpdate" arguments: nil];
}

/**
 *  删除最近会话的回调
 *
 *  @param recentSession    最近会话
 *  @param totalUnreadCount 目前总未读数
 */
- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    NSLog(@"didRemoveRecentSession");
    [_channel invokeMethod:@"onSessionUpdate" arguments: nil];
}

-(void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    NSLog(@"你被踢下线");
    [_channel invokeMethod:@"onKick" arguments: nil];
}
@end
