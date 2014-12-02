//
//  RegisterStep2View.h
//  BBK
//
//  Created by Seven on 14-11-27.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStep2View : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *houseNumId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *ownerNameTf;
@property (weak, nonatomic) IBOutlet UITextField *idCardTf;
@property (weak, nonatomic) IBOutlet UITextField *identityTf;

- (IBAction)nextStepAction:(id)sender;

@end
