//
//  InviteRegisterView.m
//  BBK
//
//  Created by Seven on 14-12-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "InviteRegisterView.h"
#import "NSString+STRegex.h"
#import "IQKeyboardManager/KeyboardManager.framework/Headers/IQKeyboardManager.h"
#import "PropertyPageView.h"
#import "LifePageView.h"
#import "MyPageView.h"
#import "SettingPageView.h"
#import "AppDelegate.h"
#import "XGPush.h"

@interface InviteRegisterView ()
{
    NSTimer *_timer;
    int countDownTime;
    UIWebView *phoneWebView;
    NSString *identityId;
}

@property (nonatomic, strong) UIPickerView *identityPicker;

@property (nonatomic, strong) NSArray *identityNameArray;
@property (nonatomic, strong) NSArray *identityIdArray;

@end

@implementation InviteRegisterView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"邀请码注册";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    self.identityNameArray = @[@"租户"];
    self.identityIdArray = @[@"2"];
    
    identityId = @"2";
    
    self.identityPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.identityPicker.showsSelectionIndicator = YES;
    self.identityPicker.delegate = self;
    self.identityPicker.dataSource = self;
    self.identityPicker.tag = 1;
    self.userTypeTf.inputView = self.identityPicker;
    self.userTypeTf.delegate = self;
}

#pragma mark -
#pragma mark Picker Data Source Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [self.identityNameArray count];
    }
    else
    {
        return 0;
    }
}

#pragma mark Picker Delegate Methods
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1)
    {
        return [self.identityNameArray objectAtIndex:row];;
    }
    else
    {
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (thePickerView.tag == 1)
    {
        self.userTypeTf.text = [self.identityNameArray objectAtIndex:row];
        identityId = [self.identityIdArray objectAtIndex:row];
    }
}

- (UIToolbar *)keyboardToolBar:(int)fieldIndex
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar sizeToFit];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.tag = fieldIndex;
    doneButton.title = @"完成";
    doneButton.style = UIBarButtonItemStyleDone;
    doneButton.action = @selector(doneClicked:);
    doneButton.target = self;
    
    
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    return toolBar;
}

- (void)doneClicked:(UITextField *)sender
{
    [self.userTypeTf resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.inputAccessoryView = [self keyboardToolBar:textField.tag];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (IBAction)getValidateCodeAction:(id)sender {
    
    NSString *mobileStr = self.mobileTf.text;
    if (![mobileStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.getValidataCodeBtn.enabled = NO;
    //生成验证码URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileStr forKey:@"mobileNo"];
    NSString *createRegCodeListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_createRegCode] params:param];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:createRegCodeListUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreateRegCode:)];
    request.tag = 3;
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"验证码发送中" andView:self.view andHUD:request.hud];
}

- (void)requestCreateRegCode:(ASIHTTPRequest *)request
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
        [Tool showCustomHUD:@"验证码发送成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        [self startValidateCodeCountDown];
    }
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
    NSString *mobileStr = self.mobileTf.text;
    NSString *validateCodeStr = self.validateCodeTf.text;
    NSString *inviteCodeStr = self.inviteCodeTf.text;
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
    if (inviteCodeStr == nil || [inviteCodeStr length] == 0) {
        [Tool showCustomHUD:@"请输入邀请码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
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
    [param setValue:inviteCodeStr forKey:@"invitationCode"];
    [param setValue:identityId forKey:@"userTypeId"];
    [param setValue:validateCodeStr forKey:@"validateCode"];
    [param setValue:mobileStr forKey:@"mobileNo"];
    [param setValue:pwdStr forKey:@"password"];
    NSString *regUserSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_invitationCodeReg] params:param];
    NSString *regUserUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_invitationCodeReg];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUserUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:regUserSign forKey:@"sign"];
    [request setPostValue:inviteCodeStr forKey:@"invitationCode"];
    [request setPostValue:identityId forKey:@"userTypeId"];
    [request setPostValue:validateCodeStr forKey:@"validateCode"];
    [request setPostValue:mobileStr forKey:@"mobileNo"];
    [request setPostValue:pwdStr forKey:@"password"];
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
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.getValidataCodeBtn.enabled == NO)
    {
        self.getValidataCodeBtn.enabled = YES;
    }
    if(self.finishBtn.enabled == NO)
    {
        self.finishBtn.enabled = YES;
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
        //邀请注册不会返回用户信息，所以再调用登陆接口一次
        //生成登陆URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.mobileTf.text forKey:@"mobileNo"];
        [param setValue:self.passwordTf.text forKey:@"password"];
        NSString *loginUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_login] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:loginUrl]];
        [request setUseCookiePersistence:NO];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestLogin:)];
        [request startAsynchronous];
    }
}

- (void)requestLogin:(ASIHTTPRequest *)request {
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
        [userModel saveAccount:self.mobileTf.text andPwd:self.passwordTf.text];
        [userModel saveIsLogin:YES];
        if([userInfo.rhUserHouseList count] > 0)
        {
            for (int i = 0; i < [userInfo.rhUserHouseList count]; i++) {
                UserHouse *userHouse = (UserHouse *)[userInfo.rhUserHouseList objectAtIndex:0];
                if (i == 0) {
                    userInfo.defaultUserHouse = userHouse;
                }
            }
        }
        [[UserModel Instance] saveUserInfo:userInfo];
        [XGPush setTag:userInfo.defaultUserHouse.cellId];
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
    [[self.tabBarController tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
    
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appdele.window.rootViewController = tabBarController;
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

@end
