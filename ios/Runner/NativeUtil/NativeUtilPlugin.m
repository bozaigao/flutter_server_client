//
//  NativeUtil.m
//  Runner
//
//  Created by 何晏波 on 2020/4/14.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "NativeUtilPlugin.h"

@implementation NativeUtilPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"www.guigug.com/native_util_plugin"
                                     binaryMessenger:[registrar messenger]];
    NativeUtilPlugin* instance = [[NativeUtilPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"checkNetworkAvailable" isEqualToString:call.method]) {
        [self checkNetworkAvailable:call result:result];
    }else if ([@"listenerScreenLock" isEqualToString:call.method]) {
        [self listenerScreenLock:call result:result];
    }
}

//检查是否有网络
- (void)checkNetworkAvailable:(FlutterMethodCall*)call result:(FlutterResult)result {
   // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
      printf("Error. Could not recover network reachability flags\n");
     result(@false);
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    BOOL network =  (isReachable && !needsConnection) ? YES : NO;
    result(@(network));
}



//锁屏和解锁监听
- (void)listenerScreenLock:(FlutterMethodCall*)call result:(FlutterResult)result {
   NSLog(@"监听屏幕锁屏与屏幕激活");
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenLockChange:) name:@"screenLockChange" object:nil];
}

-(void)screenLockChange:(NSNotification *)notification
{
     [_channel invokeMethod:@"onScreenLockChange" arguments: nil];
}
@end
