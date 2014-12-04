//
//  GoodBorrowView.m
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "GoodBorrowView.h"

@interface GoodBorrowView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation GoodBorrowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物品借用";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self refreshGoodsData];
}

- (void)refreshGoodsData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取物业物品URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"40" forKey:@"countPerPages"];
        
        NSString *getCircleOfFriendsListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_BorrowGoods] params:param];
        
        [[AFOSCClient sharedClient]getPath:getCircleOfFriendsListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           //                                           [notices removeAllObjects];
                                           //                                           notices = [Tool readJsonStrToNoticeArray:operation.responseString];
                                           //                                           if ([notices count] > 0) {
                                           //                                               Notice *notice = [notices objectAtIndex:0];
                                           //                                               self.noticeTitleLb.text = notice.title;
                                           //                                           }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
