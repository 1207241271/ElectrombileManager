//
//  XCClientManager.h
//  Electrombile
//
//  Created by 邓翔 on 15/5/14.
//  Copyright (c) 2015年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>


extern NSString *const NOTIF_AQB_RCVD_LATEST_MAPDATA;

extern NSString *const NOTIF_AQB_RCVD_LATEST_MAPDATA_INFO;
extern NSString *const NOTIF_AQB_RCVD_GETFENCE;
extern NSString *const NOTIF_RCVD_SETSOS_ACK;
extern NSString *const NOTIF_RCVD_FENCEON_ACK;
extern NSString *const NOTIF_RCVD_FENCEOFF_ACK;
extern NSString *const NOTIF_RCVD_FENCEGET_ACK;
extern NSString *const NOTIF_RCVD_SETCENTER_ACK;
extern NSString *const NOTIF_AQB_RCVD_SOS_PHONE_NUM;
extern NSString *const NOTIF_RCVD_SET_SEEKON_ACK;
extern NSString *const NOTIF_RCVD_SET_SEEKOFF_ACK;
extern NSString *const NOTIF_AQB_RCVD_RSSI_DATA;
extern NSString *const NOTIF_AQB_RCVD_MAPDATA_LIST;
//自动落锁
extern NSString *const NOTIF_RCVD_AUTOLOCKON_ACK;
extern NSString *const NOTIF_RCVD_AUTOLOCKOFF_ACK;
extern NSString *const NOTIF_RCVD_AUTOPERIODSET_ACK;
extern NSString *const NOTIF_AQB_RCVD_AUTOPERIODGET_INFO;
extern NSString *const NOTIF_AQB_RCVD_AUTOLOCKGET_INFO;
extern NSString *const NOTIF_AQB_BATTERY_INFO;
extern NSString *const NOTIF_AQB_STATUS_INFO;


typedef NS_OPTIONS(short, MQTTCmdWord) {
    CMD_WILD        = 0x0000,
    CMD_FENCE_ON   = 1,
    CMD_FENCE_OFF   = 2,
    CMD_FENCE_GET   = 3,
    CMD_TEST_GPS    = 0x00FE,
    CMD_TEST_ALARM  = 0x00FF,
    CMD_SEEK_ON     = 4,
    CMD_SEEK_OFF    = 5,
    CMD_LOCATION    = 6,
    CMD_AUTOLOCK_ON = 7,
    CMD_AUTOLOCK_OFF = 8,
    CMD_AUTOPERIOD_SET = 9,
    CMD_AUTOPERIOD_GET = 10,
    CMD_AUTOLOCK_GET=11,
    CMD_BATTERY     =12,
    CMD_STATUS_GET  =13
};

typedef NS_OPTIONS(short, serverCode) {
    APP_ERR_SUCCESS = 0,
    APP_ERR_INTERNAL = 100,
    APP_ERR_WAITING = 101,
    APP_ERR_OFFLINE = 102,
    APP_ERR_BATTERY_LEARNING =103
};

typedef NS_OPTIONS(char, geoFenceType) {
    leaveFence  = 'O',
    arriveFence = 'I',
    crossFence  = 'C'
};

typedef NS_OPTIONS(char, geoFenceShape) {
    roundFence  = 'R',
    squarFence  = 'S'
};
struct gpsData{
    short start;
    int timestamp;
    float longitude;
    float latitude;
    short course;
    char speed;
    char isgps;
};

#define NOTIF_MQTT_RCVD_CMD      @"NOTIF_MQTT_RCVD_CMD"
#define NOTIF_MQTT_RCVD_GPSDATA      @"NOTIF_MQTT_RCVD_GPSDATA"
@class XCClientManager;
@protocol SubscribeDelegate
@optional
-(void)unSubscribeSuccess;
-(void)unSubscribeFail;
-(void)subscribeSuccess;
-(void)subscribeFail;
@end



@interface XCClientManager : NSObject<SubscribeDelegate>
@property (nonatomic,weak)  id<SubscribeDelegate>   delegate;

@property (nonatomic,strong)    NSString    *IMEI;

+(instancetype)sharedClient;
- (void) subscrible:(NSString *)IMEI;
- (void) getGeoFence;
- (void) getLatandLong;
- (void) setCenterCode;
- (void) getParam;


- (void) getAutoPeriod;
- (void) getAutoLock;
- (void) getBattery;
- (void) getStatus;
@end
