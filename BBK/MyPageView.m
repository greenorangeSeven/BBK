//
//  MyPageView.m
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MyPageView.h"
#import "UIImageView+WebCache.h"

@interface MyPageView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation MyPageView

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"我的";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    UserModel *userModel = [UserModel Instance];
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:[userModel getUserValueForKey:@"photoFull"]] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", [userModel getUserValueForKey:@"regUserName"], [userModel getUserValueForKey:@"mobileNo"]];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", [userModel getUserValueForKey:@"cellName"], [userModel getUserValueForKey:@"buildingName"], [userModel getUserValueForKey:@"numberName"], [userModel getUserValueForKey:@"userTypeName"]];
}

- (void)didReceiveMemoryWarning
{
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

@end
