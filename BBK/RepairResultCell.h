//
//  RepairResultCell.h
//  BBK
//
//  Created by Seven on 14-12-12.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *scoreFrameView;
@property (weak, nonatomic) IBOutlet UIView *scoreItemView;
@property (weak, nonatomic) IBOutlet UILabel *scoreItemNameLb;
@property (weak, nonatomic) IBOutlet UILabel *scoreItemRateLb;
@property (weak, nonatomic) IBOutlet UITextView *resultContentTv;
@property (weak, nonatomic) IBOutlet UIView *resultContentView;

@end
