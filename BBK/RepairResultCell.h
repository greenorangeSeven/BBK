//
//  RepairResultCell.h
//  BBK
//
//  Created by Seven on 14-12-12.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairResultCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *scoreFrameView;
@property (weak, nonatomic) IBOutlet UITextView *resultContentTv;
@property (weak, nonatomic) IBOutlet UIView *resultContentView;
@property (weak, nonatomic) IBOutlet UIButton *submitScoreBtn;

@property (weak, nonatomic) IBOutlet UILabel *resultContentPlaceholder;

- (void)bindResultContentTvDelegate;
@end
