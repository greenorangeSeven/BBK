//
//  ShopInfoCell.h
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageIv;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLb;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressLb;
@property (weak, nonatomic) IBOutlet UILabel *shopPhoneLb;
@property (weak, nonatomic) IBOutlet UIView *distanceView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLb;

@end
