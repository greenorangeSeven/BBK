//
//  CommDetailView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "CommDetailView.h"

@interface CommDetailView ()
{
    MBProgressHUD *hud;
    UIWebView *phoneWebView;
}

@end

@implementation CommDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.titleStr;
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
}

- (void)closeAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
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

@end
