//
//  ConvenienceTableView.h
//  BBK
//
//  Created by Seven on 14-12-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BMapKit.h"

@interface ConvenienceTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate,BMKLocationServiceDelegate>
{
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

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) ShopType *type;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
