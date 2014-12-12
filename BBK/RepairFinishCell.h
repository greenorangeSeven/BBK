//
//  RepairFinishCell.h
//  BBK
//
//  Created by Seven on 14-12-12.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairFinishCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *finishView;
@property (weak, nonatomic) IBOutlet UILabel *finishTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *finishContentLb;
@property (weak, nonatomic) IBOutlet UILabel *finishCostLb;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end
