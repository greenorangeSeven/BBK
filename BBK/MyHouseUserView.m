//
//  MyHouseUserView.m
//  BBK
//
//  Created by Seven on 14-12-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MyHouseUserView.h"
#import "HouseUserCell.h"
#import "HouseUser.h"

@interface MyHouseUserView ()
{
    NSMutableArray *houseUsers;
    NSString *userTypeId;
    UserInfo *userInfo;
}

@end

@implementation MyHouseUserView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"我的房间都有谁";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    userTypeId = [userInfo.defaultUserHouse.userTypeId stringValue];
    
    [self findUserHouses];
}

- (void)findUserHouses
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //查询指定房间所绑定的用户信息
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
        
        NSString *findUserHousesUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findUserHouseList] params:param];
        [[AFOSCClient sharedClient]getPath:findUserHousesUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           [houseUsers removeAllObjects];
                                           houseUsers = [Tool readJsonStrToHouseUserArray:operation.responseString];
                                           [self.tableView reloadData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"列表获取出错");
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return houseUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HouseUserCell *cell = [tableView dequeueReusableCellWithIdentifier:HouseUserCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HouseUserCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[HouseUserCell class]]) {
                cell = (HouseUserCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    HouseUser *user = [houseUsers objectAtIndex:row];
    cell.nameLb.text = user.regUserName;
    cell.positionLb.text = [NSString stringWithFormat:@"身份:%@", user.userTypeName];
    
    if (userTypeId != 0) {
        cell.removeBtn.hidden = YES;
    }
    else
    {
        cell.removeBtn.hidden = NO;
    }
    [cell.removeBtn addTarget:self action:@selector(removeUserAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)removeUserAction:(id)sender
{
//    UIButton *btn = (UIButton *)sender;
//    if (btn) {
//        int row = btn.tag;
//        
//        Express *exp = [expresses objectAtIndex:row];
//        
//        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//        [param setValue:exp.expressId forKey:@"expressId"];
//        NSString *getExpressUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_GetExpress] params:param];
//        
//        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getExpressUrl]];
//        [request setUseCookiePersistence:NO];
//        [request setDelegate:self];
//        [request setDidFailSelector:@selector(requestFailed:)];
//        [request setDidFinishSelector:@selector(requestGetExpress:)];
//        request.tag = row;
//        [request startAsynchronous];
//        
//        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
//        [Tool showHUD:@"领取中..." andView:self.view andHUD:request.hud];
//    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
