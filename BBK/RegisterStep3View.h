//
//  RegisterStep3View.h
//  BBK
//
//  Created by Seven on 14-11-27.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStep3View : UIViewController

@property (nonatomic, strong) NSString *houseNumId;
@property (nonatomic, strong) NSString *ownerNameStr;
@property (nonatomic, strong) NSString *idCardStr;
@property (nonatomic, strong) NSString *identityIdStr;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *mobileNoTf;
@property (weak, nonatomic) IBOutlet UITextField *validateCodeTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainTf;
@property (weak, nonatomic) IBOutlet UIButton *getValidataCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

- (IBAction)getValidateCodeAction:(id)sender;
- (IBAction)finishAction:(id)sender;

@end
