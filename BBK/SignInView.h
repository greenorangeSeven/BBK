//
//  SignInView.h
//  BBK
//
//  Created by Seven on 14-12-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *luckyDrawBtn;

- (IBAction)signInAction:(id)sender;
- (IBAction)luckyDrawAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *integralLb;

@end
