//
//  TradeListView.m
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "TradeListView.h"
#import "TradeListCell.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"

@interface TradeListView ()

@end

@implementation TradeListView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"交易买卖";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.frameView.frame.size.height;
    self.tableView.frame = tableFrame;

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *headerView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    headerView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    trades = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [trades removeAllObjects];
    trades = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [trades removeAllObjects];
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
        [param setValue:self.typeId forKey:@"typeId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:@"1" forKey:@"stateId"];
        
        NSString *businessInfoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBusinessInfoByPage] params:param];
        [[AFOSCClient sharedClient] getPath:businessInfoUrl parameters:nil
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         NSMutableArray *paymentNews = [Tool readJsonStrToTradeArray:operation.responseString];
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
                                             [trades addObjectsFromArray:paymentNews];
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
            return trades.count == 0 ? 1 : trades.count;
        }
        else
            return trades.count + 1;
    }
    else
        return trades.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [trades count])
    {
        return 97.0;
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
    if ([trades count] > 0) {
        if (row < [trades count])
        {
            TradeListCell *cell = [tableView dequeueReusableCellWithIdentifier:TradeListCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"TradeListCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[TradeListCell class]]) {
                        cell = (TradeListCell *)o;
                        break;
                    }
                }
            }
            Trade *trade = [trades objectAtIndex:row];
            cell.titleLb.text = trade.title;
            
            NSMutableString *contentMuStr = [[NSMutableString alloc] init];
            if ([trade.area length] > 0) {
                [contentMuStr appendString:[NSString stringWithFormat:@"面积:%@㎡\n", trade.area]];
            }
            [contentMuStr appendString:[NSString stringWithFormat:@"评估价格:%.2f%@", trade.price, trade.priceUnitName]];
            cell.contentLb.text = [NSString stringWithString:contentMuStr];
            
            cell.phoneLb.text = [NSString stringWithFormat:@"电话:%@", trade.phone];
            
            [cell.imageIv setImageWithURL:[NSURL URLWithString:trade.imgUrlFull] placeholderImage:[UIImage imageNamed:@"loadpic"]];
            
            [cell.phoneBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.tag = row;
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

- (IBAction)telAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Trade *trade = [trades objectAtIndex:tap.tag];
        if ([trade.phone length] > 0) {
            NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", trade.phone]];
            if (!phoneWebView) {
                phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
            }
            [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        }
    }
    
    
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [trades count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Trade *trade = [trades objectAtIndex:row];
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@?accessId=%@&businessId=%@", api_base_url, htm_businessDetail , Appkey, trade.businessId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"交易详情";
        detailView.urlStr = pushDetailHtm;
        [self.navigationController pushViewController:detailView animated:YES];
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
