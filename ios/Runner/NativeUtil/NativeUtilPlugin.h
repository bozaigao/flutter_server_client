//
//  NativeUtil.h
//  Runner
//
//  Created by 何晏波 on 2020/4/14.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
NS_ASSUME_NONNULL_BEGIN

@interface NativeUtilPlugin : NSObject<FlutterPlugin>
+ (void) registerWithRegistrar;
@property FlutterMethodChannel * channel;
@end

NS_ASSUME_NONNULL_END
