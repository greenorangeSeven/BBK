//
//  GoodBorrowView.h
//  BBK
//  物品借用
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"

@interface GoodBorrowView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource, IconDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
