//
//  AppDelegate.h
//  ElectrombileManager
//
//  Created by Tao Jiang on 6/27/16.
//  Copyright © 2016 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapKit/BaiduMapAPI_Base/BMKMapManager.h>
@interface EBMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager     *mapManager;

@end

