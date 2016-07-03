//
//  EBMUserDetailViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/3.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMUserDetailViewController.h"
#import <AVOSCloud.h>

@interface EBMUserDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray    *deviceArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *labCreateTime;

@end

@implementation EBMUserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.userObjectId);
    [self getIMEIList];
    [self getCreatTime];
    // Do any additional setup after loading the view.
}

#pragma mark    -   UITableViewDataSource
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _deviceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *const  cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _deviceArray[indexPath.row];
    return cell;
}

#pragma mark    -   UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getIMEIList{
    __weak  __typeof(self)  weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"Bindings"];
    [query whereKey:@"user" equalTo:_userObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
        }
    }];
    
}

-(void)getCreatTime{
    __weak  __typeof(self)  weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:_userObjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDate  *date = objects.firstObject[@"createdAt"];
                NSDateFormatter *dateFtr = [[NSDateFormatter alloc] init];
                [dateFtr setDateFormat:@"YYYY年MM日dd"];
                weakself.labCreateTime.text = [dateFtr stringFromDate:date];
            });
        }
    }];
}

@end
