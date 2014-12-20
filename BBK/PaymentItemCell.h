//
//  PaymentItemCell.h
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *moneyLb;

@end
