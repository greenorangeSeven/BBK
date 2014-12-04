//
//  GoodBorrowView.h
//  BBK
//  物品借用
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"

@interface GoodBorrowView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate>
{
    NSMutableArray *goods;
    TQImageCache * _iconCache;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
