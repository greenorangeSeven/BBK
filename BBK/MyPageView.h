//
//  MyPageView.h
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"

@interface MyPageView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLb;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//更新头像
- (IBAction)uploadFaceAction:(id)sender;
//修改信息
- (IBAction)modifyUserInfoAction:(id)sender;
//邀请注册
- (IBAction)InviteAction:(id)sender;
//我的房间有谁
- (IBAction)houseUserAction:(id)sender;
//我的包裹
- (IBAction)myExpressAction:(id)sender;
//切换房间
- (IBAction)changeHouseAction:(id)sender;
//电子放行单
- (IBAction)releasepermitActon:(id)sender;

@end
