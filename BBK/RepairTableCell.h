//
//  RepairTableCell.h
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *starttimeLb;
@property (weak, nonatomic) IBOutlet UILabel *stateNameLb;
@property (weak, nonatomic) IBOutlet UILabel *repairContentLb;

@end
