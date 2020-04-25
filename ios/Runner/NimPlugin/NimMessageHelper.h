//
//  NimMessageHelper.h
//  flutter_nim_plugin
//
//  Created by 何晏波 on 2020/2/14.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>

@interface NimMessageHelper : NSObject
@end
@interface NIMMessage (CustomNIMMessage)
- (NSMutableDictionary *)messageToDictionary;
@end
@interface NSArray (CustomNIMMessage)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end
@interface NIMUser (CustomNIMUser)
-(NSMutableDictionary*)userToDictionary;
@end
@interface NIMRecentSession (CustomNIMRecentSession)
-(NSMutableDictionary*)recentSessionToDictionary;
@end
