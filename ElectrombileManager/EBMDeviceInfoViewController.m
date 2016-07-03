//
//  EBMDeviceInfoViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/3.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMDeviceInfoViewController.h"
#import <MapKit/MapKit.h>
#import "loTDataPointClass.h"
#import "XCClientManager.h"

@interface EBMDeviceInfoViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) XCClientManager *client;
@property (strong, nonatomic) IBOutlet UILabel *labSwitch;
@property (strong, nonatomic) IBOutlet UILabel *labAutoSwitch;
@property (strong, nonatomic) IBOutlet UILabel *labAutoPeriod;
@property (strong, nonatomic) IBOutlet UILabel *labBattery;
@property (strong, nonatomic) IBOutlet UILabel *labPlace;





@end

@implementation EBMDeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _client =  [[XCClientManager alloc]initWithIMEI:_IMEI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getStatus:) name:NOTIF_AQB_STATUS_INFO object:nil];
    
}

-(void)getStatus:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *result=[notif object][@"result"];
        short code=[[notif object][@"code"] shortValue];
        if (code==0||code==APP_ERR_BATTERY_LEARNING){
            
            [_labBattery setText:[NSString stringWithFormat:@"%d%%电量",[result[@"percent"] intValue]]];
            if ([result[@"lock"] boolValue]) {
                [_labSwitch setText:@"开"];
            }else{
                [_labSwitch setText:@"关"];
            }
            
            NSDictionary *dic = result[@"autolock"];
            if ([dic[@"isOn"] boolValue]) {
                [_labAutoSwitch setText:@"开"];
                [_labAutoPeriod setText:[NSString stringWithFormat:@"%d",[dic[@"period"] intValue]]];
            }else{
                [_labAutoSwitch setText:@"关"];
            }
            
            loTDataPointClass *point = [[loTDataPointClass alloc] initWithLatitude:[result[@"lat"] doubleValue] longitude:[result[@"lng"] doubleValue]];
            [self setPlaceFromPoint:[point getCoordinate2D] toLabel:_labPlace];
        }
    });
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)setPlaceFromPoint:(CLLocationCoordinate2D )point toLabel:(UILabel *)label
{
    CLGeocoder  *geocoder=[[CLGeocoder alloc] init];
    CLLocation  *currentLocation=[[CLLocation alloc]initWithLatitude:point.latitude longitude:point.longitude];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count>0)
            dispatch_async(dispatch_get_main_queue(), ^{
                CLPlacemark *place=[placemarks objectAtIndex:0];
                NSString *subThoroughfare=place.subThoroughfare;
                NSString *thoroughfare=place.thoroughfare;
                if (!thoroughfare) {
                    thoroughfare=@"";
                }
                if (!subThoroughfare){
                    subThoroughfare=@"";
                }
                NSString *placeName=[NSString stringWithFormat:@"%@%@%@%@",place.locality,place.subLocality,thoroughfare,subThoroughfare];
//                _latestPoint.placeName=placeName;
                [label setText:placeName];
                
            });
    }];
}
@end
