//
//  ServiceOrderView.h
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceOrderView : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLb;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *orderContentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *orderContentTv;
@property (weak, nonatomic) IBOutlet UILabel *orderDateLb;
@property (weak, nonatomic) IBOutlet UIButton *submitOrderBtn;

- (IBAction)selectOrderTimeAction:(id)sender;

- (IBAction)telServiceAction:(id)sender;
- (IBAction)submitOrderAction:(id)sender;
- (IBAction)pushServiceCostView:(id)sender;

@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIDatePicker *dateTimePicker;

@end
