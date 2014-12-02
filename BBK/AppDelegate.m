//
//  AppDelegate.m
//  BBK
//
//  Created by Seven on 14-11-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginView.h"
#import "UserInfo.h"
#import "EGOCache.h"
#import "PropertyPageView.h"
#import "LifePageView.h"
#import "MyPageView.h"
#import "SettingPageView.h"
#import "TransitionView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //启动判断登陆
    [self userLogin];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TransitionView *transitionView = [[TransitionView alloc] initWithNibName:@"TransitionView" bundle:nil];
    self.window.rootViewController = transitionView;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)userLogin
{
    UserModel *user = [UserModel Instance];
    if (user.isLogin == YES)
    {
        NSString *mobileStr = [user getUserValueForKey:@"Account"];
        NSString *pwdStr = [user getPwd];
        //生成登陆URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:mobileStr forKey:@"mobileNo"];
        [param setValue:pwdStr forKey:@"password"];
        NSString *loginUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_login] params:param];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:loginUrl]];
        [request setUseCookiePersistence:NO];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestLogin:)];
        [request startAsynchronous];
    }
    else
    {
        LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
        self.window.rootViewController = loginNav;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
    self.window.rootViewController = loginNav;
}
- (void)requestLogin:(ASIHTTPRequest *)request
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
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        LoginView *loginView = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
        UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginView];
        self.window.rootViewController = loginNav;
    }
    else
    {
        UserInfo *userInfo = [Tool readJsonStrToLoginUserInfo:request.responseString];
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        [userModel saveIsLogin:YES];
        [userModel saveValue:userInfo.regUserId ForKey:@"regUserId"];
        [userModel saveValue:userInfo.regUserName ForKey:@"regUserName"];
        [userModel saveValue:userInfo.mobileNo ForKey:@"mobileNo"];
        [userModel saveValue:userInfo.nickName ForKey:@"nickName"];
        [[EGOCache globalCache] setObject:userInfo forKey:UserInfoCache withTimeoutInterval:3600 * 24 * 356];
        
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

    self.window.rootViewController = tabBarController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
