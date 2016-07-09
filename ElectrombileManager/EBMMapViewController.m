//
//  EBMMapViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/9.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMMapViewController.h"
#import "XCClientManager.h"
#import "loTDataPointClass.h"

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <CoreLocation/CoreLocation.h>

@interface EBMMapViewController ()<BMKMapViewDelegate>
@property (strong, nonatomic) IBOutlet BMKMapView   *mapView;
@property (strong, nonatomic) BMKPointAnnotation    *carAnnotation;
@property (strong, nonatomic) CLLocationManager     *locationManager;
@property (strong, nonatomic) loTDataPointClass     *latestPoint;


@end

@implementation EBMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.delegate = self;
    _carAnnotation = [[BMKPointAnnotation alloc] init];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ){
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    [self requestLastedData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLastestCarGPSData:) name:NOTIF_AQB_RCVD_LATEST_MAPDATA object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLastestCarGPSDataInfo:) name:NOTIF_AQB_RCVD_LATEST_MAPDATA_INFO object:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadLastestCarGPSDataInfo:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView removeAnnotation:_carAnnotation];
        NSDictionary *dic=[notif object];
        
        
        NSDictionary *result=[dic objectForKey:@"result"];
        
        _latestPoint=[[loTDataPointClass alloc] initWithLatitude:[result[@"lat"] floatValue] longitude:[result[@"lng"] floatValue] speed:[result[@"speed"] intValue] course:[result[@"course"] intValue] timestamp:[result[@"timestamp"] doubleValue]];
        _carAnnotation.coordinate = [_latestPoint getCoordinate2D];
        //        _carAnnotation.title = [self datetextFromDataPoint:_latestPoint];
        
        //        [self setPlaceFromPoint:[_latestPoint getCoordinate2D] toLabel:_carLocationLabel];
        
        
        BMKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
        theRegion.center=_carAnnotation.coordinate;
        if (_mapView.region.span.latitudeDelta>0.01) {
            theRegion.span.latitudeDelta=0.01;
            theRegion.span.longitudeDelta=0.01;
        }else{
            theRegion.span.longitudeDelta=_mapView.region.span.longitudeDelta;
            theRegion.span.latitudeDelta=_mapView.region.span.latitudeDelta;
        }
        [_mapView addAnnotation:_carAnnotation];
        [_mapView selectAnnotation:_carAnnotation animated:YES];
        [_mapView setRegion:theRegion animated:YES];
    });
}
-(void)reloadLastestCarGPSData:(NSNotification *)notif{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mapView removeAnnotation:_carAnnotation];
//        [_waitingTimer invalidate];
        _latestPoint = [notif object];
        if(_latestPoint != nil){
           
            
            // ------ 设置地点
//            [self setPlaceFromPoint:[_latestPoint getCoordinate2D] toLabel:_carLocationLabel];
            
            _carAnnotation.coordinate = [_latestPoint getCoordinate2D];
//            _carAnnotation.title = [self datetextFromDataPoint:_latestPoint];
            
            
            BMKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
            theRegion.center=_carAnnotation.coordinate;
            if (_mapView.region.span.latitudeDelta>0.01) {
                theRegion.span.latitudeDelta=0.01;
                theRegion.span.longitudeDelta=0.01;
            }else{
                theRegion.span.longitudeDelta=_mapView.region.span.longitudeDelta;
                theRegion.span.latitudeDelta=_mapView.region.span.latitudeDelta;
            }
            [_mapView setRegion:theRegion animated:YES];
            
        }
        [_mapView addAnnotation:_carAnnotation];
        [_mapView selectAnnotation:_carAnnotation animated:YES];
    });
}

-(void)requestLastedData{
    [_client getLatandLong];
}

- (IBAction)locate:(id)sender {
    [self requestLastedData];
}
#pragma mark    -   mapkitDelegate
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView *carAnnotationView=[[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"carAnnotationView"];
        carAnnotationView.image=[UIImage imageNamed:@"map_mylocation"];
        carAnnotationView.canShowCallout=YES;
        return carAnnotationView;
    }
    return nil;
}


@end
