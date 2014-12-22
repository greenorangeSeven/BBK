//
//  ModifyUserInfoView.h
//  BBK
//
//  Created by Seven on 14-12-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyUserInfoView : UIViewController

@property (weak, nonatomic) UIView *parentView;

@property (weak, nonatomic) IBOutlet UITextField *nickNameTf;
@property (weak, nonatomic) IBOutlet UITextField *oldPassWordTf;
@property (weak, nonatomic) IBOutlet UITextField *newsPassWordTf;
@property (weak, nonatomic) IBOutlet UITextField *newsPassWordAginTf;

@end
