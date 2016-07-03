//
//  EBMUserTableViewController.m
//  ElectrombileManager
//
//  Created by yangxu on 16/7/2.
//  Copyright © 2016年 Wuhan Huake Xunce Co., Ltd. All rights reserved.
//

#import "EBMUserTableViewController.h"

#import "EBMUserDetailViewController.h"

#import "MJRefresh.h"
#import <AVOSCloud.h>
@interface EBMUserTableViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray        *userArray;
@property (strong, nonatomic) NSMutableArray        *userObjectIdArray;

@end

@implementation EBMUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userArray = [[NSMutableArray alloc] init];
    _userObjectIdArray = [[NSMutableArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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

#pragma mark    -   UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EBMUserDetailViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EBMUserDetailViewController"];
    viewController.userObjectId = _userObjectIdArray[indexPath.row];
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
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    query.limit = 20;
    [query whereKey:@"username" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
                [weakself.userObjectIdArray addObject:object.objectId];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)footerRefresh{
    __weak __typeof(self) weakself  =   self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    query.limit = 10;
    [query whereKey:@"username" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
                [weakself.userObjectIdArray addObject:object.objectId];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark    -   UISearchBarDelegate
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    _userArray = [[NSMutableArray alloc] init];
    _userObjectIdArray = [[NSMutableArray alloc] init];
    __weak __typeof(self) weakself  =   self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    query.limit = 20;
    [query whereKey:@"username" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
                [weakself.userObjectIdArray addObject:object.objectId];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    _userArray = [[NSMutableArray alloc] init];
    _userObjectIdArray = [[NSMutableArray alloc] init];
    __weak __typeof(self) weakself  =  self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    query.limit = 20;
    [query whereKey:@"username" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
                [weakself.userObjectIdArray addObject:object.objectId];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _userArray = [[NSMutableArray alloc] init];
    _userObjectIdArray = [[NSMutableArray alloc] init];
    __weak __typeof(self) weakself  =   self;
    
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    query.limit = 20;
    [query whereKey:@"username" containsString:_searchBar.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (AVObject *object in objects) {
                [weakself.userArray addObject:object[@"username"]];
                [weakself.userObjectIdArray addObject:object.objectId];
            }
            [weakself.tableView reloadData];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}


@end
