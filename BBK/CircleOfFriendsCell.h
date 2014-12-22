//
//  CircleOfFriendsCell.h
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface CircleOfFriendsCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate>
{
    NSArray *imageList;
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLb;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)loadCircleOfFriendsImage:(Topic *)topic;
@property (weak, nonatomic) UINavigationController *navigationController;

@end
