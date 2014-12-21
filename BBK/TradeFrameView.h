//
//  TradeFrameView.h
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TradeListView.h"

@interface TradeFrameView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *item1Btn;
@property (weak, nonatomic) IBOutlet UIButton *item2Btn;
@property (weak, nonatomic) IBOutlet UIButton *item3Btn;
@property (weak, nonatomic) IBOutlet UIView *mainView;

- (IBAction)item1Action:(id)sender;
- (IBAction)item2Action:(id)sender;
- (IBAction)item3Action:(id)sender;

@property (strong, nonatomic) TradeListView *esjyView;
@property (strong, nonatomic) TradeListView *fwcsView;
@property (strong, nonatomic) TradeListView *fwczView;

@end
