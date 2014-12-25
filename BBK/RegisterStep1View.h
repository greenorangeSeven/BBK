//
//  RegisterStep1View.h
//  BBK
//
//  Created by Seven on 14-11-27.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStep1View : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cityTf;
@property (weak, nonatomic) IBOutlet UITextField *communityTf;
@property (weak, nonatomic) IBOutlet UITextField *buildingTf;
@property (weak, nonatomic) IBOutlet UITextField *unitTf;
@property (weak, nonatomic) IBOutlet UITextField *houseNumTf;

- (IBAction)nextStepAction:(id)sender;
- (IBAction)inviteRegisterAction:(id)sender;

@end
