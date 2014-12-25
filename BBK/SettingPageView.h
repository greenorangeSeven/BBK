//
//  SettingPageView.h
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface SettingPageView : UIViewController<SGFocusImageFrameDelegate,UIAlertViewDelegate>
{
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *switchLb;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;
//注销用户
- (IBAction)logoutAction:(id)sender;
//关于步步高智慧社区
- (IBAction)aboutBBGAction:(id)sender;
//版本更新
- (IBAction)checkVersionUpdate:(id)sender;
//清除缓存
- (IBAction)clearCacheAction:(id)sender;

@end
