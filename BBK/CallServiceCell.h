//
//  CallServiceCell.h
//  BBK
//
//  Created by Seven on 14-12-3.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallServiceCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIImageView *servicePicIv;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLb;
@property (weak, nonatomic) IBOutlet UILabel *servicePhoneLb;

@end
