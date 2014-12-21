//
//  PropertyPageView.m
//  BBK
//
//  Created by Seven on 14-12-1.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PropertyPageView.h"
#import "NoticeTableView.h"
#import "Notice.h"
#import "CallServiceView.h"
#import "GoodBorrowView.h"
#import "ExpressView.h"
#import "AddRepairView.h"
#import "ADInfo.h"
#import "AddSuitWorkView.h"
#import "CommDetailView.h"
#import "PushGatePassView.h"
#import "PaymentListView.h"
#import "TradeFrameView.h"

@interface PropertyPageView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation PropertyPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = [[UserModel Instance] getUserValueForKey:@"cellName"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"签到有奖" style:UIBarButtonItemStyleBordered target:self action:@selector(signInAction:)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.scrollView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.view.bounds.size.height);
    
    [self getADVData];
    [self getNotice];
}

- (void)signInAction:(id *)sender
{
    
}

- (void)viewDidUnload
{
    _refreshHeaderView = nil;
    [super viewDidUnload];
}

//// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    return;
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
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
        [self getNotice];
    }
}


- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141788149430600" forKey:@"typeId"];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           advDatas = [Tool readJsonStrToAdinfoArray:operation.responseString];
                                           int length = [advDatas count];
                                           
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:length-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:i];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:0];
                                               [itemArray addObject:item];
                                           }
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 135) delegate:self imageItems:itemArray isAuto:YES];
                                           [bannerView scrollToIndex:0];
                                           [self.advIv addSubview:bannerView];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:advIndex];
    if (adv)
    {
        NSString *adDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_adDetail ,adv.adId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"详情";
        detailView.urlStr = adDetailHtm;
        detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    advIndex = index;
}

- (void)getNotice
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取新闻列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"1" forKey:@"countPerPages"];
        NSString *getNoticeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPushInfo] params:param];
        
        [[AFOSCClient sharedClient]getPath:getNoticeListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSMutableArray *notices = [Tool readJsonStrToNoticeArray:operation.responseString];
                                           if ([notices count] > 0) {
                                               notice = [notices objectAtIndex:0];
                                               self.noticeTitleLb.text = notice.title;
                                           }
                                           notices = nil;
                                           [self doneLoadingTableViewData];
                                           self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.bounds.size.height+1);
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           [self doneLoadingTableViewData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[UserModel Instance] getUserValueForKey:@"cellPhone"]]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

//物业通知
- (IBAction)noticesAction:(id)sender {
    NoticeTableView *noticeView = [[NoticeTableView alloc] init];
    noticeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:noticeView animated:YES];
}

//物业呼叫
- (IBAction)callServiceAction:(id)sender {
    CallServiceView *callServiceView = [[CallServiceView alloc] init];
    callServiceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:callServiceView animated:YES];
}

//物品借用
- (IBAction)goodBorrowAction:(id)sender {
    GoodBorrowView *borrowView = [[GoodBorrowView alloc] init];
    borrowView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:borrowView animated:YES];
}

//快递收发
- (IBAction)expressAction:(id)sender {
    ExpressView *expressView = [[ExpressView alloc] init];
    expressView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:expressView animated:YES];
}

//物业报修
- (IBAction)addRepairAction:(id)sender {
    AddRepairView *addRepairView = [[AddRepairView alloc] init];
    addRepairView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addRepairView animated:YES];
}

//投诉建议
- (IBAction)addSuitWorkAction:(id)sender {
    AddSuitWorkView *addSuitView = [[AddSuitWorkView alloc] init];
    addSuitView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addSuitView animated:YES];
}

//访客通行证
- (IBAction)pushGatePassAction:(id)sender {
    PushGatePassView *gatePassView = [[PushGatePassView alloc] init];
    gatePassView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gatePassView animated:YES];
}

//账单推送
- (IBAction)pushPaymentListView:(id)sender {
    PaymentListView *paymentListView = [[PaymentListView alloc] init];
    paymentListView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:paymentListView animated:YES];
}

//交易买卖
- (IBAction)pushTradeViewAction:(id)sender {
    TradeFrameView *tradeView = [[TradeFrameView alloc] init];
    tradeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tradeView animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    bannerView.delegate = self;
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    bannerView.delegate = nil;
}

- (IBAction)noticeDetailAction:(id)sender {
    if (notice) {
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_pushDetailHtm , notice.pushId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"物业通知";
        detailView.urlStr = pushDetailHtm;
        detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}
@end
