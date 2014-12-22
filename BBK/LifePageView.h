//
//  LifePageView.h
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"


@interface LifePageView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate,IconDownloaderDelegate,SGFocusImageFrameDelegate>
{
    NSMutableArray *topics;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    TQImageCache * _iconCache;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;

- (void)refreshCircleOfFriendsData:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//生活查询
- (IBAction)LifeReferAction:(id)sender;
//便民服务
- (IBAction)convenienceTypeAction:(id)sender;
//周边商家
- (IBAction)ShopTypeAction:(id)sender;
//悦月刊
- (IBAction)pushMonthlyViewAction:(id)sender;
//步步高商城
- (IBAction)pushBuBuGaoWeb:(id)sender;
//家有喜事（服务预约）
- (IBAction)orderServiceAction:(id)sender;
//社区活动
- (IBAction)activityViewAction:(id)sender;
//社区朋友圈
- (IBAction)pushCircleOfFriendsView:(id)sender;


@end
