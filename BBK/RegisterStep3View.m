//
//  RegisterStep3View.m
//  BBK
//
//  Created by Seven on 14-11-27.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RegisterStep3View.h"
#import "NSString+STRegex.h"
#import "EGOCache.h"
#import "PropertyPageView.h"
#import "LifePageView.h"
#import "MyPageView.h"
#import "SettingPageView.h"
#import "AppDelegate.h"

@interface RegisterStep3View ()
{
    NSTimer *_timer;
    int countDownTime;
    UIWebView *phoneWebView;
}

@end

@implementation RegisterStep3View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"注册";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
}

- (void)didReceiveMemoryWarning {
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

- (IBAction)getValidateCodeAction:(id)sender {
    [self startValidateCodeCountDown];
}

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", servicephone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (void)startValidateCodeCountDown
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
    countDownTime = 60;
}

- (void)timerFunc
{
    if (countDownTime > 0) {
        self.getValidataCodeBtn.enabled = NO;
        [self.getValidataCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%d)" ,countDownTime] forState:UIControlStateDisabled];
        [self.getValidataCodeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
    else
    {
        self.getValidataCodeBtn.enabled = YES;
        [self.getValidataCodeBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.getValidataCodeBtn setTitleColor:[UIColor colorWithRed:251/255.0 green:67/255.0 blue:79/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_timer invalidate];
    }
    countDownTime --;
}

- (IBAction)finishAction:(id)sender {
    
    NSString *mobileStr = self.mobileNoTf.text;
    NSString *validateCodeStr = self.validateCodeTf.text;
    NSString *pwdStr = self.passwordTf.text;
    NSString *pwdAgainStr = self.passwordAgainTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (validateCodeStr == nil || [validateCodeStr length] == 0) {
        [Tool showCustomHUD:@"请输入验证码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (pwdStr == nil || [pwdStr length] == 0) {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if ([pwdStr isEqualToString:pwdAgainStr] == NO) {
        [Tool showCustomHUD:@"两次密码输入不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.finishBtn.enabled = NO;
    //生成注册URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.ownerNameStr forKey:@"rUserName"];
    [param setValue:self.idCardStr forKey:@"idCardLast4"];
    [param setValue:self.identityIdStr forKey:@"userTypeId"];
    [param setValue:self.houseNumId forKey:@"numberId"];
    [param setValue:validateCodeStr forKey:@"validateCode"];
    [param setValue:mobileStr forKey:@"mobileNo"];
    [param setValue:pwdStr forKey:@"password"];
    NSString *regUserSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_regUser] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_regUser];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:[self.ownerNameStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"rUserName"];
    NSLog([NSString stringWithFormat:@"rUserName=%@", [self.ownerNameStr stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]);
    [request setPostValue:self.idCardStr forKey:@"idCardLast4"];
    [request setPostValue:self.identityIdStr forKey:@"userTypeId"];
    [request setPostValue:self.houseNumId forKey:@"numberId"];
    [request setPostValue:validateCodeStr forKey:@"validateCode"];
    [request setPostValue:mobileStr forKey:@"mobileNo"];
    [request setPostValue:pwdStr forKey:@"password"];
    [request setPostValue:regUserSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegUser:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"注册中..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestRegUser:(ASIHTTPRequest *)request
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
        self.finishBtn.enabled = YES;
        return;
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonStrToLoginUserInfo:request.responseString];
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        [userModel saveIsLogin:YES];
        [userModel saveAccount:self.mobileNoTf.text andPwd:self.passwordTf.text];
        [userModel saveValue:userInfo.regUserId ForKey:@"regUserId"];
        [userModel saveValue:userInfo.regUserName ForKey:@"regUserName"];
        [userModel saveValue:userInfo.mobileNo ForKey:@"mobileNo"];
        [userModel saveValue:userInfo.nickName ForKey:@"nickName"];
        [userModel saveValue:userInfo.photoFull ForKey:@"photoFull"];
        [[EGOCache globalCache] setObject:userInfo forKey:UserInfoCache withTimeoutInterval:3600 * 24 * 356];
        
        if([userInfo.rhUserHouseList count] > 0)
        {
            UserHouse *userHouse = (UserHouse *)[userInfo.rhUserHouseList objectAtIndex:0];
            [userModel saveValue:[userHouse.userTypeId stringValue] ForKey:@"userTypeId"];
            [userModel saveValue:userHouse.userTypeName ForKey:@"userTypeName"];
            [userModel saveValue:userHouse.numberName ForKey:@"numberName"];
            [userModel saveValue:userHouse.buildingName ForKey:@"buildingName"];
            [userModel saveValue:userHouse.cellName ForKey:@"cellName"];
            [userModel saveValue:userHouse.cellId ForKey:@"cellId"];
            [userModel saveValue:userHouse.phone ForKey:@"cellPhone"];
            [userModel saveValue:userHouse.numberId ForKey:@"numberId"];
        }
        else
        {
            [userModel saveValue:@"" ForKey:@"userTypeId"];
            [userModel saveValue:@"" ForKey:@"userTypeName"];
            [userModel saveValue:@"" ForKey:@"numberName"];
            [userModel saveValue:@"" ForKey:@"buildingName"];
            [userModel saveValue:@"" ForKey:@"cellName"];
            [userModel saveValue:@"" ForKey:@"cellId"];
            [userModel saveValue:@"" ForKey:@"cellPhone"];
            [userModel saveValue:@"" ForKey:@"numberId"];
        }
        
        [self gotoTabbar];
    }
}

-(void)gotoTabbar
{
    //物业
    PropertyPageView *propertyPage = [[PropertyPageView alloc] initWithNibName:@"PropertyPageView" bundle:nil];
    propertyPage.tabBarItem.image = [UIImage imageNamed:@"tab_pro"];
    propertyPage.tabBarItem.title = @"物业";
    UINavigationController *propertyPageNav = [[UINavigationController alloc] initWithRootViewController:propertyPage];
    
    //生活
    LifePageView *lifePage = [[LifePageView alloc] initWithNibName:@"LifePageView" bundle:nil];
    lifePage.tabBarItem.image = [UIImage imageNamed:@"tab_life"];
    lifePage.tabBarItem.title = @"生活";
    UINavigationController *lifePageNav = [[UINavigationController alloc] initWithRootViewController:lifePage];
    
    //我的
    MyPageView *myPage = [[MyPageView alloc] initWithNibName:@"MyPageView" bundle:nil];
    myPage.tabBarItem.image = [UIImage imageNamed:@"tab_my"];
    myPage.tabBarItem.title = @"我的";
    UINavigationController *myPageNav = [[UINavigationController alloc] initWithRootViewController:myPage];
    
    //设置
    SettingPageView *settingPage = [[SettingPageView alloc] initWithNibName:@"SettingPageView" bundle:nil];
    settingPage.tabBarItem.image = [UIImage imageNamed:@"tab_setting"];
    settingPage.tabBarItem.title = @"设置";
    UINavigationController *settingPageNav = [[UINavigationController alloc] initWithRootViewController:settingPage];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:
                                        propertyPageNav,
                                        lifePageNav,
                                        myPageNav,
                                        settingPageNav,
                                        nil];
    [[tabBarController tabBar] setSelectedImageTintColor:[Tool getColorForMain]];
    
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appdele.window.rootViewController = tabBarController;
}

@end
