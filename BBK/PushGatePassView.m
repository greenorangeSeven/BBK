//
//  PushGatePassView.m
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PushGatePassView.h"
#import "NSString+STRegex.h"
#import "GatePassInfoCell.h"

@interface PushGatePassView ()
{
    UserInfo *userInfo;
}

@end

@implementation PushGatePassView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"访客通行证";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"发布通行证" style:UIBarButtonItemStyleBordered target:self action:@selector(pushGatePassAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
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
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    self.tableView.tableHeaderView = self.headerView;
    
    passinfos = [[NSMutableArray alloc] initWithCapacity:20];
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self reload:YES];
}

- (void)pushGatePassAction:(id *)sender
{
    [self.mobileTf resignFirstResponder];
    NSString *mobileNo = self.mobileTf.text;
    if (![mobileNo isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //生成访客通行证URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileNo forKey:@"mobileNo"];
    [param setValue:@"24" forKey:@"hours"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    NSString *createPassCodeSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_createPassCode] params:param];
    NSString *createPassCodeUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createPassCode];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createPassCodeUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:createPassCodeSign forKey:@"sign"];
    [request setPostValue:mobileNo forKey:@"mobileNo"];
    [request setPostValue:@"24" forKey:@"hours"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreatePassCode:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"发布通行证..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)requestCreatePassCode:(ASIHTTPRequest *)request
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"发布成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
        
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [passinfos removeAllObjects];
    passinfos = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [passinfos removeAllObjects];
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
        
        //生成获取业主放行单列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        NSString *findPassInfoListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPassInfoByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:findPassInfoListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *passinfoNews = [Tool readJsonStrToPassInfoArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           int count = [passinfoNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [passinfos addObjectsFromArray:passinfoNews];
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
            return passinfos.count == 0 ? 1 : passinfos.count;
        }
        else
            return passinfos.count + 1;
    }
    else
        return passinfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [passinfos count])
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
    if ([passinfos count] > 0) {
        if (row < [passinfos count])
        {
            GatePassInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:GatePassInfoCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GatePassInfoCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[GatePassInfoCell class]]) {
                        cell = (GatePassInfoCell *)o;
                        break;
                    }
                }
            }
            PassInfo *info = [passinfos objectAtIndex:row];
            cell.timeLb.text = info.starttime;
            cell.mobileLb.text = info.passMobile;
            cell.codeLb.text = [NSString stringWithFormat:@"验证码:%@", info.code];
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
    if (row >= [passinfos count]) {
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
