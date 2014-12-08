//
//  CircleOfFriendsCell.h
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleOfFriendsCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLb;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;

@end
