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

@interface PropertyPageView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation PropertyPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = [[UserModel Instance] getUserValueForKey:@"cellName"];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    [self getNotice];
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
                                           [notices removeAllObjects];
                                           notices = [Tool readJsonStrToNoticeArray:operation.responseString];
                                           if ([notices count] > 0) {
                                               Notice *notice = [notices objectAtIndex:0];
                                               self.noticeTitleLb.text = notice.title;
                                           }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}


@end
