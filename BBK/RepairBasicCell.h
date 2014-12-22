//
//  RepairBasicCell.h
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface RepairBasicCell : UITableViewCell
<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MWPhotoBrowserDelegate>
{
    NSArray *imageList;
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;

@property (weak, nonatomic) IBOutlet UIView *basicView;
@property (weak, nonatomic) IBOutlet UILabel *repairTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *repairTypeLb;
@property (weak, nonatomic) IBOutlet UILabel *repairContentLb;
@property (weak, nonatomic) IBOutlet UIView *repairImageView;
@property (weak, nonatomic) IBOutlet UIView *repairImageFrameView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)loadRepairImage:(NSArray *)imageList;
@property (weak, nonatomic) UINavigationController *navigationController;

@end
