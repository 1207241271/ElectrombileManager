//
//  AppDelegate.m
//  ElectrombileManager
//
//  Created by Tao Jiang on 6/27/16.
//  Copyright © 2016 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMAppDelegate.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudCrashReporting/AVOSCloudCrashReporting.h>


static NSString *const APPId = @"5wk8ccseci7lnss55xfxdgj9xn77hxg3rppsu16o83fydjjn";
static NSString *const ClientKey = @"yovqy5zy16og43zwew8i6qmtkp2y6r9b18zerha0fqi5dqsw";

@interface EBMAppDelegate ()

@end

@implementation EBMAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AVOSCloudCrashReporting enable];
    [AVOSCloud setApplicationId:APPId clientKey:ClientKey];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:@"kMZFpf8w9TjO7dK2iKq19vM3rXOzHrvy" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
