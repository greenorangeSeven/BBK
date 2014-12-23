//
//  PaymentListView.m
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PaymentListView.h"
#import "UIImageView+WebCache.h"
#import "Payment.h"
#import "PaymentCell.h"
#import "PaymentMonthDetailView.h"

@interface PaymentListView ()
{
    UserInfo *userInfo;
}

@end

@implementation PaymentListView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物业账单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", userInfo.regUserName, userInfo.mobileNo];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.defaultUserHouse.userTypeName];
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headView;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    payments = [[NSMutableArray alloc] initWithCapacity:20];
    
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [payments removeAllObjects];
    payments = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [payments removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        
        //月账单列表
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.buildingName forKey:@"buildName"];
        [param setValue:userInfo.defaultUserHouse.numberName forKey:@"numberName"];
        [param setValue:userInfo.regUserName forKey:@"regUserName"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        
        NSString *paymentByGroupSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPaymentByGroup] params:param];
        
        [param setValue:Appkey forKey:@"accessId"];
        [param setValue:paymentByGroupSign forKey:@"sign"];
        
        NSString *paymentByGroupcUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_findPaymentByGroup];
        
        [[AFOSCClient sharedClient] postPath:paymentByGroupcUrl parameters:param
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *paymentNews = [Tool readJsonStrToPaymentArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           int count = [paymentNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [payments addObjectsFromArray:paymentNews];
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           [self doneLoadingTableViewData];
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"列表获取出错");
                                       //如果是刷新
                                       [self doneLoadingTableViewData];
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       isLoading = NO;
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
        isLoading = YES;
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return payments.count == 0 ? 1 : payments.count;
        }
        else
            return payments.count + 1;
    }
    else
        return payments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [payments count])
    {
        return 68.0;
    }
    else
    {
        return 47.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([payments count] > 0) {
        if (row < [payments count])
        {
            PaymentCell *cell = [tableView dequeueReusableCellWithIdentifier:PaymentCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PaymentCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[PaymentCell class]]) {
                        cell = (PaymentCell *)o;
                        break;
                    }
                }
            }
            Payment *pay = [payments objectAtIndex:row];
            cell.monthLb.text = pay.dbildateStr;
            cell.infoLb.text = [NSString stringWithFormat:@"%@%@%@物业账单", pay.unitname, pay.vbuildingname, pay.vhnum];
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [payments count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Payment *payment = [payments objectAtIndex:row];
        if (payment) {
            PaymentMonthDetailView *detailView = [[PaymentMonthDetailView alloc] init];
            detailView.month = payment.dbildateStr;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
        [self performSelector:@selector(reload:)];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning
{
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
