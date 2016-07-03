//
//  TableViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/2.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMMainTableViewController.h"
#import <AVOSCloud.h>


@interface EBMMainTableViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign)   NSInteger   userCount;
@property (nonatomic, assign)   NSInteger
    deviceCount;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EBMMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self queryUserFromCreateDate:[NSDate dateWithTimeIntervalSince1970:0]];
    [self queryDeviceFromCreateDate:[NSDate dateWithTimeIntervalSince1970:0]];
    
    _userCount = 0;
}

#pragma mark    -   dataSource
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *const cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"用户";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)_userCount];
    }else{
        cell.textLabel.text = @"设备";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)_deviceCount];
    }
    return cell;
}

#pragma mark    -   delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIViewController *viewcontroller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMUserTableViewController"];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }else{
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMDeviceTableViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


-(void)queryUserFromCreateDate:(NSDate *)date{
    __typeof(self) __weak weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                weakself.userCount += objects.count;
                [weakself queryUserFromCreateDate:objects.lastObject[@"createdAt"]];
            }else{
                weakself.userCount += objects.count;
                    [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }];
}

-(void)queryDeviceFromCreateDate:(NSDate *)date{
    
    __typeof(self) __weak weakself = self;
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    [query whereKey:@"createdAt" greaterThan:date];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count != 0) {
                weakself.deviceCount += objects.count;
                [weakself queryDeviceFromCreateDate:objects.lastObject[@"createdAt"]];
            }else{
                weakself.deviceCount += objects.count;
                [weakself.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }];
}

@end
