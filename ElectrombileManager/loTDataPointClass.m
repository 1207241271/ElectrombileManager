//
//  loTDataPointClass.m
//  Electrombile
//
//  Created by yangxu on 16/3/31.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "loTDataPointClass.h"
#import "JZLocationConverter.h"
#import <AVObject.h>

@implementation loTDataPointClass

#pragma mark    -   init
/**主方法
 */
- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude  speed:(int)speed course:(int)course timestamp:(double)timestamp {
    self=[super init];
    if (self!=nil) {
        _latitude=latitude;
        _longitude=longitude;
        _speed=speed;
        _course=course;
        _timestamp=timestamp;
    
    }
    return self;
}


- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
             longitude:(CLLocationDegrees)longitude {
    
    return [self initWithLatitude:latitude longitude:longitude speed:0 course:0 timestamp:0];
}

+(loTDataPointClass *)dataPointWithDic:(NSDictionary *)dicGPSData{
    loTDataPointClass *dataPoint = [[loTDataPointClass alloc] initWithLatitude:[dicGPSData[@"lat"] doubleValue]
                                                                     longitude:[dicGPSData[@"lon"] doubleValue]
                                                                         speed:[dicGPSData[@"speed"] intValue]
                                                                        course:[dicGPSData[@"course"] intValue]
                                                                     timestamp:0];

    return dataPoint;
}

+(loTDataPointClass *)dataPointWithAVGPSDataObj:(AVObject *)avGPSDataObj{
    loTDataPointClass *dataPoint = [[loTDataPointClass alloc] initWithLatitude:[avGPSDataObj[@"lat"] doubleValue]
                                                                     longitude:[avGPSDataObj[@"lon"] doubleValue]
                                                                         speed:[avGPSDataObj[@"speed"] intValue]
                                                                        course:[avGPSDataObj[@"course"] intValue]
                                                                     timestamp:[avGPSDataObj[@"time"] intValue]];
    return dataPoint;
}

#pragma mark    -   location
- (CLLocation*)getCLLocation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self getCoordinate2D].latitude longitude:[self getCoordinate2D].longitude];
    return location;
}

-(CLLocationCoordinate2D)getCoordinate2D{
    CLLocationCoordinate2D coor;
    coor.longitude = _longitude;
    coor.latitude = _latitude;
    return [JZLocationConverter wgs84ToBd09:coor];
}

#pragma mark    -   coder
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(_timestamp) forKey:@"timeStamp"];
    [aCoder encodeObject:@(_longitude) forKey:@"longitude"];
    [aCoder encodeObject:@(_latitude) forKey:@"latitude"];
    [aCoder encodeObject:@(_distance) forKey:@"distance"];
    [aCoder encodeObject:@(_speed) forKey:@"speed"];
    [aCoder encodeObject:_placeName forKey:@"placeName"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (self) {
        _timestamp=[[aDecoder decodeObjectForKey:@"timeStamp"] doubleValue];
        _longitude=[[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
        _latitude=[[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
        _distance=[[aDecoder decodeObjectForKey:@"distance"] doubleValue];
        _speed=[[aDecoder decodeObjectForKey:@"speed"] doubleValue];
        _placeName=[aDecoder decodeObjectForKey:@"placeName"];
    }
    return self;
}

@end
