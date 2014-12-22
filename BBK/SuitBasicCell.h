//
//  SuitBasicCell.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface SuitBasicCell : UITableViewCell
<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSArray *imageList;
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (weak, nonatomic) UINavigationController *navigationController;

@property (weak, nonatomic) IBOutlet UIView *basicView;
@property (weak, nonatomic) IBOutlet UILabel *suitTimeLb;
@property (weak, nonatomic) IBOutlet UILabel *suitTypeLb;
@property (weak, nonatomic) IBOutlet UILabel *suitContentLb;
@property (weak, nonatomic) IBOutlet UIView *suitImageFrameView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)loadSuitImage:(NSArray *)imageList;

@end

