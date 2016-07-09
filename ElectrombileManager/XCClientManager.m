
//  XCClientManager.m
//  Electrombile
//
//  Created by 邓翔 on 15/5/14.
//  Copyright (c) 2015年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "XCClientManager.h"
#import <MQTTKit.h>

#import "loTDataPointClass.h"

NSString *const MQTT_HOST       =@"www.xiaoan110.com";

NSString *const NOTIF_AQB_RCVD_LATEST_MAPDATA       =@"NOTIF_AQB_RCVD_LATEST_MAPDATA";
NSString *const NOTIF_AQB_RCVD_LATEST_MAPDATA_INFO  =@"NOTIF_AQB_RCVD_LATEST_MAPDATA_INFO";
NSString *const NOTIF_AQB_RCVD_GETFENCE             =@"NOTIF_AQB_RCVD_GETFENCE";
NSString *const NOTIF_RCVD_SETSOS_ACK               =@"NOTIF_RCVD_SETSOS_ACK";
NSString *const NOTIF_RCVD_FENCEON_ACK              =@"NOTIF_RCVD_FENCEON_ACK";
NSString *const NOTIF_RCVD_FENCEOFF_ACK             =@"NOTIF_RCVD_FENCOFF_ACK";
NSString *const NOTIF_RCVD_FENCEGET_ACK             =@"NOTIF_RCVD_FENCEGET_ACK";
NSString *const NOTIF_RCVD_SETCENTER_ACK            =@"NOTIF_RCVD_SETCENTER_ACK";
NSString *const NOTIF_AQB_RCVD_SOS_PHONE_NUM        =@"NOTIF_AQB_RCVD_SOS_PHONE_NUM";
NSString *const NOTIF_RCVD_SET_SEEKON_ACK           =@"NOTIF_RCVD_SET_SEEKON_ACK";
NSString *const NOTIF_RCVD_SET_SEEKOFF_ACK          =@"NOTIF_RCVD_SET_SEEKOFF_ACK";
NSString *const NOTIF_AQB_RCVD_RSSI_DATA            =@"NOTIF_AQB_RSSI_DATA";//信号强度数值
NSString *const NOTIF_AQB_RCVD_MAPDATA_LIST         =@"NOTIF_AQB_RCVD_MAPDATA_LIST";
//自动落锁
NSString *const NOTIF_RCVD_AUTOLOCKON_ACK           =@"NOTIF_RCVD_AUTOLOCKON_ACK";
NSString *const NOTIF_RCVD_AUTOLOCKOFF_ACK          =@"NOTIF_RCVD_AUTOLOCKOFF_ACK";
NSString *const NOTIF_RCVD_AUTOPERIODSET_ACK        =@"NOTIF_RCVD_AUTOPERIODSET_ACK";
NSString *const NOTIF_AQB_RCVD_AUTOPERIODGET_INFO   =@"NOTIF_AQB_RCVD_AUTOPERIODGET_INFO";
NSString *const NOTIF_AQB_RCVD_AUTOLOCKGET_INFO     =@"NOTIF_AQB_RCVD_AUTOLOCKGET_INFO";
NSString *const NOTIF_AQB_BATTERY_INFO              =@"NOTIF_AQB_BATTERY_INFO";
NSString *const NOTIF_AQB_STATUS_INFO               =@"NOTIF_AQB_STATUS_INFO";



static XCClientManager *instance = nil;

@interface XCClientManager()
@property (strong, nonatomic)NSString       *oldIMEI;
@end

@implementation XCClientManager {
    MQTTClient *client;
}

+ (instancetype)sharedClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        //NSString *clientID = AppDelegate.username;
        NSString *clientID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        client = [[MQTTClient alloc] initWithClientId:clientID];
        
        __block XCClientManager *Manager = self;
        [client setMessageHandler:^(MQTTMessage *message) {
            [Manager didReceiveData:message.payload formTopic:message.topic];
        }];
        
        // connect the MQTT client
        [client connectToHost:MQTT_HOST
            completionHandler:^(MQTTConnectionReturnCode code) {
                if (code == ConnectionAccepted) {
                    // when the client is connected, subscribe to the topic to receive message.
                }
            }];
        
    }
    return self;
}

-(void)subscrible:(NSString *)IMEI{
    [client unsubscribe:[NSString stringWithFormat:@"dev2app/%@/cmd",_oldIMEI]  withCompletionHandler:nil];
    [client unsubscribe:[NSString stringWithFormat:@"dev2app/%@/gps", _oldIMEI] withCompletionHandler:nil];
    [client unsubscribe:[NSString stringWithFormat:@"dev2app/%@/433", _oldIMEI] withCompletionHandler:nil];

    _IMEI = IMEI;
    [client subscribe:[NSString stringWithFormat:@"dev2app/%@/cmd", IMEI] withCompletionHandler:^(NSArray *grantedQos) {
        [self getStatus];
    }];
    [client subscribe:[NSString stringWithFormat:@"dev2app/%@/gps", IMEI] withCompletionHandler:^(NSArray *grantedQos) {
        [self getLatandLong];
    }];
}

- (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}





#pragma mark - SetData




- (void)getGeoFence{
    [self publishDataWithCmdWord:CMD_FENCE_GET data:nil];
}



- (void) getLatandLong
{
    [self publishDataWithCmdWord:CMD_LOCATION data:nil];
}
//自动落锁

- (void) getAutoLock
{
    [self publishDataWithCmdWord:CMD_AUTOLOCK_GET data:nil];
}


- (void) getAutoPeriod
{
    [self publishDataWithCmdWord:CMD_AUTOPERIOD_GET data:nil];
}

- (void) getBattery
{
    [self publishDataWithCmdWord:CMD_BATTERY data:nil];
}

- (void) getStatus{
    [self publishDataWithCmdWord:CMD_STATUS_GET data:nil];
}

-(void) setSOSCode:(NSString*)aPhoneNum forOrdinal:(NSUInteger)ordinal
{
    switch (ordinal) {
        case 0:
            [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"SOS,A,%@#",aPhoneNum]];
            break;
            
        case 1:
            [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"SOS,A,,%@#",aPhoneNum]];
            break;
            
        case 2:
            [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"SOS,A,,,%@#",aPhoneNum]];
            break;
            
        default:
            break;
    }
}
-(void) deleteSOSCode:(NSString*)aPhoneNum
{
    [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"SOS,D,%@#",aPhoneNum]];
}
- (void)deleteAllSOSCode
{
    [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"SOS,D,1,2,3#"]];
}
-(void) setCenterCode
{
//    [self publishDataWithCmdWord:CMD_FENCE_GET data:[NSString stringWithFormat:@"CENTER,A,%@#",AppDelegate.username]];
}

- (void)getParam {
    [self publishDataWithCmdWord:CMD_FENCE_GET data:@"SOS?"];
}




#pragma mark - ReceiveData

- (void)didReceiveData:(NSData*)data formTopic:(NSString *)topic{
    NSError *err;
    if (data == nil) {
        NSLog(@"接收到的数据为空");
    }
    NSDictionary *dic=[ NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    NSLog(@"接收到的数据是：%@",dic.description);
    unsigned short startSig;
    startSig = ntohs(startSig);
    if ([topic isEqualToString:[NSString stringWithFormat:@"dev2app/%@/gps",_IMEI]]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        NSLog(@"gps-------lat: %@ lng: %@",[dic objectForKey:@"lat"],[dic objectForKey:@"lng"]);
        struct gpsData gpsdata;
        gpsdata.latitude = [[dic objectForKey:@"lat"] floatValue];
        gpsdata.longitude = [[dic objectForKey:@"lng"] floatValue];
        gpsdata.timestamp = [[dic objectForKey:@"time"] intValue];
        
        loTDataPointClass *dataPoint = [[loTDataPointClass alloc] initWithLatitude:gpsdata.latitude
                                                                         longitude:gpsdata.longitude
                                                                             speed:gpsdata.speed
                                                                            course:gpsdata.course
                                                                         timestamp:gpsdata.timestamp];
        dataPoint.isGPS = YES;
        //用消息将该最近数据传出去
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_LATEST_MAPDATA object:dataPoint];
        
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        return;
    }
    //找车信号强度
    if ([topic isEqualToString:[NSString stringWithFormat:@"dev2app/%@/433",_IMEI]]) {
        NSLog(@"433..........................................");
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        NSNumber *strength = [dic objectForKey:@"intensity"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_RSSI_DATA object:strength];
        return;
    }
    
    //自动落锁
    if ([topic isEqualToString:[NSString stringWithFormat:@"dev2app/%@/autolock",_IMEI]]) {
        NSLog(@"autolock>>>>>>>>>>>>>>>>>>>>>>>>");
        NSDictionary *dic=[ NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        short cmd=[[dic objectForKey:@"cmd"] shortValue];
        NSNumber *result=[NSNumber numberWithShort:[[dic objectForKey:@"result"] shortValue]];
        NSLog(@"接收中心收到的result是：%@",result);
        switch (cmd) {

            default:
                break;
        }
        return;
    }
    
    
    //cmd命令解析
    if ([topic isEqualToString:[NSString stringWithFormat:@"dev2app/%@/cmd",_IMEI]]) {
        short cmd;
        short result;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        cmd = [[dic objectForKey:@"cmd"] shortValue];
        result = [[dic objectForKey:@"code"] shortValue];
        NSNumber *number = [[NSNumber alloc]initWithShort:result];
        switch (cmd) {
            case CMD_FENCE_ON:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_SETSOS_ACK object:dic];
                break;
            case CMD_FENCE_OFF:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_SETSOS_ACK object:dic];
                break;
            case CMD_FENCE_GET:
                if (0==[number shortValue]) {
                    number=[dic objectForKey:@"state"] ;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_GETFENCE object:number];
                }
                break;
            case CMD_SEEK_ON:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_SET_SEEKON_ACK object:dic];
                break;
            case CMD_SEEK_OFF:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_SET_SEEKOFF_ACK object:dic];
                break;
            case CMD_LOCATION:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_LATEST_MAPDATA_INFO object:dic];
                break;
            case CMD_AUTOLOCK_ON:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_AUTOLOCKON_ACK object:number];
                break;
            case CMD_AUTOLOCK_OFF:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_AUTOLOCKON_ACK object:number];
                break;
            case CMD_AUTOPERIOD_SET:
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RCVD_AUTOPERIODSET_ACK object:number];
                break;
            case CMD_AUTOPERIOD_GET:
                if (0==[number shortValue]) {
                    number=[dic objectForKey:@"period"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_AUTOPERIODGET_INFO object:number];
                }
                break;
            case CMD_AUTOLOCK_GET:
                if (0==[number shortValue]) {
                    number=[dic objectForKey:@"state"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_RCVD_AUTOLOCKGET_INFO object:number];
                }
                break;
            case CMD_BATTERY:
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_BATTERY_INFO object:dic];
                break;
            case CMD_STATUS_GET:
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AQB_STATUS_INFO object:dic];
            default:
                break;
        }
    }
}

#pragma mark - PublishData
- (void)publishDataWithCmdWord:(MQTTCmdWord)cmdWord data:(NSString*)stringData {
    NSMutableDictionary *dic;
    NSError *err;
    NSData *jsonData;
    dic = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:cmdWord] forKey:@"cmd"];
    if (stringData) {
        [dic setObject:[NSNumber numberWithInt:[stringData intValue]] forKey:@"period"];
    }
    jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    NSLog(@"%@ ",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    //cmd to json
    if(err != nil&&dic)
    {
//        NSLog(@"error是 %@",err);
    }else{
        [self publishData:jsonData];
    }
    
    
}

- (void)publishData:(NSData*)payload {
    [client publishData:payload toTopic:[NSString stringWithFormat:@"app2dev/%@/cmd", _IMEI] withQos:AtMostOnce retain:NO completionHandler:nil];
    NSLog(@"send__________%@__________",_IMEI);

}

@end
