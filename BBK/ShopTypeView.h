//
//  ShopTypeView.h
//  BBK
//
//  Created by Seven on 14-12-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import <CoreLocation/CoreLocation.h>
#import "BMapKit.h"

@interface ShopTypeView : UIViewController<
UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate,BMKLocationServiceDelegate>
{
    NSMutableArray *types;
    TQImageCache * _iconCache;
    MBProgressHUD *hud;
    
    //tableView
    NSMutableArray *shops;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    BMKMapPoint myPoint;
    BMKLocationService* _locService;
    double latitude;
    double longitude;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSString *typeId;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
