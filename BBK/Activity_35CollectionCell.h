//
//  Activity_35CollectionCell.h
//  NewWorld
//
//  Created by Seven on 14-7-19.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Activity_35CollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageIv;
@property (strong, nonatomic) IBOutlet UIView *bg;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UILabel *dateLb;
@property (strong, nonatomic) IBOutlet UILabel *conditionLb;
@property (strong, nonatomic) IBOutlet UILabel *telephoneLb;

@property (strong, nonatomic) IBOutlet UIButton *praiseBtn;
@property (strong, nonatomic) IBOutlet UIButton *attendBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkDetailBtn;

@end
