//
//  CustomAttachment.h
//  Runner
//
//  Created by 何晏波 on 2020/4/16.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface CustomAttachment :  NSObject<NIMCustomAttachment>
@property (nonatomic,strong)    NSDictionary* value;
@end

NS_ASSUME_NONNULL_END
