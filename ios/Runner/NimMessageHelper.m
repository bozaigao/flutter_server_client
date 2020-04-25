//
//  NimMessageHelper.m
//  flutter_nim_plugin
//
//  Created by 何晏波 on 2020/2/14.
//

#import "NimMessageHelper.h"

@implementation NimMessageHelper
@end

@implementation NIMMessage (CustomNIMMessage)
- (NSMutableDictionary *)messageToDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    switch (self.messageType) {
        case NIMMessageTypeText:
            dict[@"messageType"] = @"NIMMessageTypeText";
            break;
        case NIMMessageTypeImage:
            dict[@"messageType"] = @"NIMMessageTypeImage";
            break;
        case NIMMessageTypeAudio:
            dict[@"messageType"] = @"NIMMessageTypeAudio";
            break;
        case NIMMessageTypeCustom:
            dict[@"messageType"] = @"NIMMessageTypeCustom";
            break;
        default:
            break;
    }
    dict[@"from"] = self.from;
    dict[@"session"] = @{@"sessionId":self.session.sessionId,@"sessionType":@"NIMSessionTypeP2P"};
    dict[@"messageId"] = self.messageId;
    dict[@"text"] = self.text;
    NIMImageObject *imageObject= nil;
    NIMAudioObject *audioObject= nil;
    switch (self.messageType) {
        case NIMMessageTypeImage:
            imageObject = self.messageObject;
            dict[@"messageObject"] = @{@"displayName":imageObject.displayName,@"path":imageObject.path,@"thumbPath":imageObject.thumbPath,@"url":imageObject.url,@"thumbUrl":imageObject.thumbUrl,
                                       @"size":@{@"width":[[NSNumber numberWithDouble:imageObject.size.width] stringValue] ,
                                                 @"height":[[NSNumber numberWithDouble:imageObject.size.height] stringValue]
                                       },
                                       @"fileLength":[[NSNumber numberWithDouble:imageObject.fileLength] stringValue],
                                       @"md5":imageObject.md5
            };
            break;
        case NIMMessageTypeAudio:
            audioObject = self.messageObject;
            dict[@"messageObject"] = @{@"path":audioObject.path,@"url":audioObject.url,@"duration":[[NSNumber numberWithDouble:audioObject.duration] stringValue],
                                       @"md5":audioObject.md5
            };
            break;
        default:
            break;
    }
    dict[@"setting"] = @{@"historyEnabled":@(self.setting.historyEnabled),
                         @"roamingEnabled":@(self.setting.roamingEnabled),
                         @"syncEnabled":@(self.setting.syncEnabled),
                         @"shouldBeCounted":@(self.setting.shouldBeCounted),
                         @"apnsEnabled":@(self.setting.apnsEnabled),
                         @"apnsWithPrefix":@(self.setting.apnsWithPrefix),
                         @"routeEnabled":@(self.setting.routeEnabled),
                         @"teamReceiptEnabled":@(self.setting.teamReceiptEnabled),
                         @"persistEnable":@(self.setting.persistEnable),
                         @"scene":self.setting.scene,
                         @"isSessionUpdate":@(self.setting.isSessionUpdate),
                         
    };
    dict[@"apnsContent"] = self.apnsContent;
    dict[@"apnsPayload"] = self.apnsPayload;
    dict[@"remoteExt"] = self.remoteExt;
    dict[@"localExt"] = self.localExt;
    dict[@"timestamp"] = [[NSNumber numberWithDouble:self.timestamp] stringValue];
    switch (self.deliveryState) {
        case NIMMessageDeliveryStateFailed:
            dict[@"deliveryState"] = @"NIMMessageDeliveryStateFailed";
            break;
        case NIMMessageDeliveryStateDelivering:
            dict[@"deliveryState"] = @"NIMMessageDeliveryStateDelivering";
            break;
        case NIMMessageDeliveryStateDeliveried:
            dict[@"deliveryState"] = @"NIMMessageDeliveryStateDeliveried";
            break;
        default:
            break;
    }
    switch (self.attachmentDownloadState) {
        case NIMMessageAttachmentDownloadStateNeedDownload:
            dict[@"attachmentDownloadState"] = @"NIMMessageAttachmentDownloadStateNeedDownload";
            break;
        case NIMMessageAttachmentDownloadStateFailed:
            dict[@"attachmentDownloadState"] = @"NIMMessageAttachmentDownloadStateFailed";
            break;
        case NIMMessageAttachmentDownloadStateDownloading:
            dict[@"attachmentDownloadState"] = @"NIMMessageAttachmentDownloadStateDownloading";
            break;
        case NIMMessageAttachmentDownloadStateDownloaded:
            dict[@"attachmentDownloadState"] = @"NIMMessageAttachmentDownloadStateDownloaded";
            break;
        default:
            break;
    }
    dict[@"isReceivedMsg"] = @(self.isReceivedMsg);
    dict[@"isOutgoingMsg"] = @(self.isOutgoingMsg);
    dict[@"isPlayed"] = @(self.isPlayed);
    dict[@"isDeleted"] = @(self.isDeleted);
    dict[@"isRemoteRead"] = @(self.isRemoteRead);
    dict[@"senderName"] = self.senderName;
    switch (self.senderClientType) {
        case NIMLoginClientTypeUnknown:
            dict[@"senderClientType"] = @"NIMLoginClientTypeUnknown";
            break;
        case NIMLoginClientTypeAOS:
            dict[@"senderClientType"] = @"NIMLoginClientTypeAOS";
            break;
        case NIMLoginClientTypeiOS:
            dict[@"senderClientType"] = @"NIMLoginClientTypeiOS";
            break;
        default:
            break;
    }
    return dict;
}
@end

@implementation NSArray (CustomNIMMessage)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end

@implementation NIMUser (CustomNIMUser)
-(NSMutableDictionary*)userToDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"userId"] = self.userId;
    dict[@"alias"] = self.alias;
    dict[@"ext"] = self.ext;
    dict[@"serverExt"] = self.serverExt;
    dict[@"userInfo"] = @{@"nickName":self.userInfo.nickName,
                          @"avatarUrl":self.userInfo.avatarUrl,
                          @"thumbAvatarUrl":self.userInfo.thumbAvatarUrl,
                          @"sign":self.userInfo.sign,
                          @"gender":self.userInfo.gender == NIMUserGenderMale?@"NIMUserGenderMale":@"NIMUserGenderFemale",
                          @"email":self.userInfo.email,
                          @"birth":self.userInfo.birth,
                          @"mobile":self.userInfo.mobile,
                          @"ext":self.userInfo.ext
    };
    return dict;
}
@end
