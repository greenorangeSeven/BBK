//
//  ActivityDetailView.m
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ActivityDetailView.h"

@interface ActivityDetailView ()
{
    MBProgressHUD *hud;
    UIWebView *phoneWebView;
}

@end

@implementation ActivityDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.titleStr;
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
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    NSURL *url = [[NSURL alloc]initWithString:self.urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.webView.delegate = self;
    
    [self.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", self.activity.heartCount] forState:UIControlStateNormal];
    if ([self.activity.isJoin isEqualToString:@"1"]) {
        [self.attendBtn setTitle:[NSString stringWithFormat:@"  已参与(%d)", self.activity.userCount]  forState:UIControlStateNormal];
    }
    else
    {
        [self.attendBtn setTitle:[NSString stringWithFormat:@"  我要参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    if (hud != nil) {
        [hud hide:YES];
    }
}

#pragma 浏览器链接处理
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"telphone"])
    {
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
        if (!phoneWebView) {
            phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)praiseAction:(id)sender {
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //查询当前有效的活动列表
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.activity.activityId forKey:@"activityId"];
        NSString *praiseActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addActivityHeart] params:param];
        [[AFOSCClient sharedClient]getPath:praiseActivityUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
//                                               return;
                                           }
                                           else
                                           {
                                               [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                               self.activity.heartCount += 1;
                                               [self.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", self.activity.heartCount] forState:UIControlStateNormal];
                                           }
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
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

- (IBAction)attendAction:(id)sender {
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //查询当前有效的活动列表
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.activity.activityId forKey:@"activityId"];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        NSString *addCancelInActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCancelInActivity] params:param];
        [[AFOSCClient sharedClient]getPath:addCancelInActivityUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
                                               NSString *hudStr = @"";
                                               if([self.activity.isJoin isEqualToString:@"1"] == YES)
                                               {
                                                   self.activity.userCount -= 1;
                                                   hudStr = @"取消参与";
                                                   self.activity.isJoin = @"0";
                                                   [self.attendBtn setTitle:[NSString stringWithFormat:@"  我要参与(%d)", self.activity.userCount] forState:UIControlStateNormal];
                                               }
                                               else
                                               {
                                                   hudStr = @"已参与";
                                                   self.activity.isJoin = @"1";
                                                    self.activity.userCount += 1;
                                                   [self.attendBtn setTitle:[NSString stringWithFormat:@"  已参与(%d)", self.activity.userCount]  forState:UIControlStateNormal];
                                               }
                                               [Tool showCustomHUD:hudStr andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                           }
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
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

@end
