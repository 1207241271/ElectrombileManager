//
//  EBMDeviceInfoViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/3.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMDeviceInfoViewController.h"
#import "EBMUserDetailViewController.h"
#import "EBMMapViewController.h"

#import <AVOSCloud.h>
#import <MapKit/MapKit.h>
#import "loTDataPointClass.h"
#import "XCClientManager.h"

@interface EBMDeviceInfoViewController ()<MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) XCClientManager *client;
@property (strong, nonatomic) IBOutlet UILabel *labSwitch;
@property (strong, nonatomic) IBOutlet UILabel *labAutoSwitch;
@property (strong, nonatomic) IBOutlet UILabel *labAutoPeriod;
@property (strong, nonatomic) IBOutlet UILabel *labBattery;
@property (strong, nonatomic) IBOutlet UILabel *labPlace;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray    *userArray;
@property (strong, nonatomic) NSMutableArray    *userObjectIdArray;


@end

@implementation EBMDeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _client =  [XCClientManager sharedClient];
    [_client subscrible:_IMEI];
    [self getUserObjectList];
    
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
        }else if (code==APP_ERR_OFFLINE){
            [_labSwitch setText:@"设备离线"];
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
                [label setText:placeName];
            });
    }];
}
-(void)getUserObjectList{
    __weak  __typeof(self)  weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"Bindings"];
    [query whereKey:@"IMEI" equalTo:_IMEI];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            for (AVObject *object in objects) {
//                [weakself.userObjectIdArray addObject:object[@"user"]];
                AVUser *user = object[@"user"];
                NSLog(@"%@",[user objectForKey:@"username"]);
                [weakself.userObjectIdArray addObject:user.objectId];
                [weakself getUserNameWithUserObjectId:user.objectId];
            }
        }
    }];
    
}

-(void)getUserNameWithUserObjectId:(NSString *)objectId{
    __weak  __typeof(self)  weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
            }
            if (weakself.userArray.count == weakself.userObjectIdArray.count) {
                [weakself.tableView reloadData];
            }
        }
    }];
}

#pragma mark    -   UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _userArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *const  cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _userArray[indexPath.row];
    return cell;
}
- (IBAction)enterMap:(id)sender {
    EBMMapViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMMapViewController"];
    viewController.client = _client;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark    -   UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EBMUserDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMUserDetailViewController"];
    viewController.userObjectId = _userObjectIdArray[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
    
}



@end
