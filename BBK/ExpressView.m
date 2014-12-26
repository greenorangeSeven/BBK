//
//  ExpressView.m
//  BBK
//
//  Created by Seven on 14-12-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ExpressView.h"
#import "ExpressCell.h"
#import "ExpressHistoryView.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"

@interface ExpressView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation ExpressView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"我的快递";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    if([self.present isEqualToString:@"present"] == YES)
    {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(closeAction)];
        leftBtn.tintColor = [Tool getColorForMain];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", userInfo.regUserName, userInfo.mobileNo];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.defaultUserHouse.userTypeName];
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-33);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    expresses = [[NSMutableArray alloc] initWithCapacity:20];
    [self refreshExpressData:YES];
}

- (void)closeAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"0"]) {
            [self.tableView setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}

- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableView];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [expresses removeAllObjects];
    expresses = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [expresses removeAllObjects];
    isLoadOver = NO;
}

- (void)refreshExpressData:(BOOL)noRefresh
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
        
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        
        //生成获取我的快递URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:userInfo.mobileNo forKey:@"mobileNo"];
        [param setValue:@"0" forKey:@"stateId"];
        
        NSString *getMyExpressListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_Express] params:param];
        
        [[AFOSCClient sharedClient]getPath:getMyExpressListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSMutableArray *expressNews = [Tool readJsonStrToExpressArray:operation.responseString];
                                       self.expressNumLb.text = [Tool readJsonStrToExpressNum:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           int count = [expressNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [expresses addObjectsFromArray:expressNews];
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
            return expresses.count == 0 ? 1 : expresses.count;
        }
        else
            return expresses.count + 1;
    }
    else
        return expresses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row > [expresses count])
    {
        return 40.0;
    }
    else
    {
        return 62.0;
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
    if ([expresses count] > 0) {
        if (row < [expresses count])
        {
            ExpressCell *cell = [tableView dequeueReusableCellWithIdentifier:ExpressCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ExpressCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[ExpressCell class]]) {
                        cell = (ExpressCell *)o;
                        break;
                    }
                }
            }
            
            Express *exp = [expresses objectAtIndex:row];
            cell.timeLb.text = exp.timeDiff;
            [cell.getExpressBtn setTag:row];
            [cell.getExpressBtn addTarget:self action:@selector(getExpressAction:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无未领取的快递" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

- (IBAction)getExpressAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn) {
        int row = btn.tag;
        
        Express *exp = [expresses objectAtIndex:row];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:exp.expressId forKey:@"expressId"];
        NSString *getExpressUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_GetExpress] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getExpressUrl]];
        [request setUseCookiePersistence:NO];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestGetExpress:)];
        request.tag = row;
        [request startAsynchronous];
        
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"领取中..." andView:self.view andHUD:request.hud];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestGetExpress:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        [expresses removeObjectAtIndex:request.tag];
        [self.tableView reloadData];
        self.expressNumLb.text = [NSString stringWithFormat:@"%d", [self.expressNumLb.text intValue] - 1];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [expresses count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        
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
        [self performSelector:@selector(refreshExpressData:)];
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
        [self refreshExpressData:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)telAction:(id)sender
{
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (IBAction)expressHistoryAction:(id)sender {
    ExpressHistoryView *historyView = [[ExpressHistoryView alloc] init];
    [self.navigationController pushViewController:historyView animated:YES];
}

- (IBAction)kd100Action:(id)sender {
    NSString *pushDetailHtm = @"http://m.kuaidi100.com";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"快递物流查询";
    detailView.urlStr = pushDetailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
