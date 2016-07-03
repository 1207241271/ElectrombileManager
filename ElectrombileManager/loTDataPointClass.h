//
//  loTDataPointClass.h
//  Electrombile
//
//  Created by yangxu on 16/3/31.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class AVObject;

@interface loTDataPointClass : NSObject
#pragma mark - data get
@property(nonatomic, assign, readonly)double    longitude;
@property(nonatomic, assign, readonly)double    latitude;
@property(nonatomic, assign, readonly)int    speed;
@property(nonatomic, assign, readonly)int    course;
@property(nonatomic, assign, readonly)double    timestamp;
@property(nonatomic, assign)BOOL      isGPS;
#pragma mark - data calculate
@property(nonatomic, strong)NSString            *placeName;
@property(nonatomic, assign)double    distance;


- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
                       longitude:(CLLocationDegrees)longitude
                           speed:(int)speed
                          course:(int)course
                       timestamp:(double)timestamp
;

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude;
+(loTDataPointClass *)dataPointWithDic:(NSDictionary *)dictGPSData;
+(loTDataPointClass *)dataPointWithAVGPSDataObj:(AVObject *)avGPSDataObj;
-(CLLocation*)getCLLocation;
-(CLLocationCoordinate2D)getCoordinate2D;

@end
