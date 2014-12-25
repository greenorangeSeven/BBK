//
//  SettingPageView.m
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "SettingPageView.h"
#import "LoginView.h"
#import "AppDelegate.h"
#import "CommDetailView.h"
#import "SDImageCache.h"
#import "XGPush.h"

@interface SettingPageView ()
{
    UIWebView *phoneWebView;
    NSString *appPath;
}

@end

@implementation SettingPageView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"设置";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    [self getADVData];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141857144700000" forKey:@"typeId"];
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

- (IBAction)logoutAction:(id)sender {
    //设置登录并保存用户信息
    UserModel *userModel = [UserModel Instance];
    [userModel saveIsLogin:NO];
    [userModel logoutUser];
    [userModel saveAccount:@"" andPwd:@""];
    
    UserHouse *defaultHouse = [userModel getUserInfo].defaultUserHouse;
    
    [XGPush delTag:defaultHouse.cellId];
    
    LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appdele.window.rootViewController = loginNav;
}

//关于步步高智慧社区
- (IBAction)aboutBBGAction:(id)sender {
    NSString *bubugaoHtm = [NSString stringWithFormat:@"%@%@", api_base_url, htm_about];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"关于步步高智慧社区";
    detailView.urlStr = bubugaoHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

//清除缓存
- (IBAction)clearCacheAction:(id)sender {
    float tmpSize = [[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
    [[SDImageCache sharedImageCache] clearDisk];
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"清理缓存(%.2fM)",tmpSize] : [NSString stringWithFormat:@"清理缓存(%.2fK)",tmpSize * 1024];
    [Tool showCustomHUD:clearCacheName andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
}

//版本更新
- (IBAction)checkVersionUpdate:(id)sender
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成版本更新URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1" forKey:@"sysType"];
        NSString *findSysUpdateUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findSysUpdate] params:param];
        
        [[AFOSCClient sharedClient]getPath:findSysUpdateUrl parameters:Nil
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
                                               NSString *appversion = [[json objectForKey:@"data"] objectForKey:@"version"];
                                               appPath = [[json objectForKey:@"data"] objectForKey:@"fileurl"];
                                               if( [appversion intValue] > [AppVersionCode intValue])
                                               {
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"悦生活有新版了\n您需要更新吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                                                   alert.tag = 0;
                                                   [alert show];
                                               }
                                               else
                                               {
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您当前已是最新版本！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
                                                   [alert show];
                                               }
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"获取出错");
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                   }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == 0)
        {
            //            NSString *updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", appPath];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appPath]];
        }
    }
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
    
    BOOL isPushOn = NO;
    
    if(IS_IOS8){
        isPushOn = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    }
    else
    {
        if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
            isPushOn = NO;
        }
        else
        {
            isPushOn = YES;
        }
    }
    if (isPushOn) {
        self.switchLb.text = @"已开启";
        self.switchLb.textColor = [Tool getColorForMain];
    }
    else
    {
        self.switchLb.text = @"已关闭";
        self.switchLb.textColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    bannerView.delegate = nil;
}

@end
