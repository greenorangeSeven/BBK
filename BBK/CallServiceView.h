//
//  CallServiceView.h
//  BBK
//
//  Created by Seven on 14-12-3.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface CallServiceView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate,SGFocusImageFrameDelegate>
{
    NSMutableArray *services;
    TQImageCache * _iconCache;
    MBProgressHUD *hud;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (strong, nonatomic) UIImageView *advIv;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
