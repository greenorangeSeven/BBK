//
//  GoodBorrowCell.h
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodBorrowCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *frameView;
@property (weak, nonatomic) IBOutlet UIImageView *goodPicIv;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLb;
@property (weak, nonatomic) IBOutlet UILabel *goodNumberLb;

@end
