//
//  CircleOfFriendsFullCell.h
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface CircleOfFriendsFullCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDataSource, UITableViewDelegate,MWPhotoBrowserDelegate>
{
    NSArray *imageList;
    NSArray *replyList;
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;
@property (weak, nonatomic) UINavigationController *navigationController;

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLb;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *typeNameLb;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *heartBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)loadCircleOfFriendsImage:(TopicFull *)topic;
- (void)loadCircleOfFriendsReply:(TopicFull *)topic;

@end
