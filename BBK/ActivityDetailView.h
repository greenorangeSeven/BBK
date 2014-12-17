//
//  ActivityDetailView.h
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

@interface ActivityDetailView : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) Activity *activity;
@property (weak, nonatomic) NSString *titleStr;
@property (weak, nonatomic) NSString *urlStr;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) IBOutlet UIButton *praiseBtn;
@property (strong, nonatomic) IBOutlet UIButton *attendBtn;

- (IBAction)praiseAction:(id)sender;
- (IBAction)attendAction:(id)sender;

@end
