//
//  InviteRegisterView.h
//  BBK
//
//  Created by Seven on 14-12-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteRegisterView : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mobileTf;
@property (weak, nonatomic) IBOutlet UITextField *validateCodeTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTf;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeTf;
@property (weak, nonatomic) IBOutlet UITextField *userTypeTf;
@property (weak, nonatomic) IBOutlet UIButton *getValidataCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

- (IBAction)getValidateCodeAction:(id)sender;
- (IBAction)finishAction:(id)sender;

@end
