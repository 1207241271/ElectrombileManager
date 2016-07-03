//
//  EBMDeviceTableViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/2.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMDeviceTableViewController.h"
#import "EBMDeviceInfoViewController.h"
#import <AVOSCloud.h>
#import "MJRefresh.h"
@interface EBMDeviceTableViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray    *deviceArray;






@end

@implementation EBMDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceArray = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _searchBar.delegate = self;
    [self refresh];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    EBMDeviceInfoViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMDeviceInfoViewController"];
    viewController.IMEI = _deviceArray[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark    -   MJRefresh
-(void)refresh{
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    header.stateLabel.textColor = [UIColor blackColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor blackColor];
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
    
    MJRefreshBackStateFooter *footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
    footer.stateLabel.textColor = [UIColor blackColor];
    footer.hidden = YES;
    
    self.tableView.mj_footer = footer;
}

-(void)headerRefresh{
    __weak __typeof(self) weakself  =   self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    query.limit = 20;
    [query whereKey:@"IMEI" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)footerRefresh{
    __weak __typeof(self) weakself  =   self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    query.limit = 10;
    [query whereKey:@"IMEI" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark    -   UISearchDelegate
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    _deviceArray = [[NSMutableArray alloc]init];
    __weak __typeof(self) weakself  =   self;
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    query.limit = 20;
    [query whereKey:@"IMEI" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _deviceArray = [[NSMutableArray alloc]init];
    __weak __typeof(self) weakself  =   self;
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    query.limit = 20;
    [query whereKey:@"IMEI" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _deviceArray = [[NSMutableArray alloc]init];
    __weak __typeof(self) weakself  =   self;
    AVQuery *query = [AVQuery queryWithClassName:@"DID"];
    query.limit = 20;
    [query whereKey:@"IMEI" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.deviceArray addObject:object[@"IMEI"]];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}



@end
