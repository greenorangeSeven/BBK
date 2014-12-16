//
//  BorrowGoodFromView.h
//  BBK
//
//  Created by Seven on 14-12-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorrowGoodFromView : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) BorrowGood *good;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageIv;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLb;
@property (weak, nonatomic) IBOutlet UILabel *goodNumberLb;
@property (weak, nonatomic) IBOutlet UIView *goodBoxView;

@property (weak, nonatomic) IBOutlet UILabel *borrowTypeLb;
@property (weak, nonatomic) IBOutlet UILabel *borrowTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *borrowNumLb;

- (IBAction)selectTypeAction:(id)sender;
- (IBAction)selectTimeAction:(id)sender;
- (IBAction)selectNumAction:(id)sender;

@property (strong, nonatomic) UIView *parentView;

@property (strong, nonatomic) UIDatePicker *dateTimePicker;

@end
