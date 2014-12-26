//
//  ShopTypeView.m
//  BBK
//
//  Created by Seven on 14-12-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ShopTypeView.h"
#import "LifeReferCell.h"
#import "ShopInfoCell.h"
#import "ShopInfo.h"
#import "UIImageView+WebCache.h"

@interface ShopTypeView ()

@end

@implementation ShopTypeView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"周边商家";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    //适配iOS7uinavigationbar遮挡的问题
//    if(IS_IOS7)
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        if (IS_IOS8) {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self;
    }else {
        //提示用户无法进行定位操作
    }
    // 开始定位
    [self.locationManager startUpdatingLocation];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    shops = [[NSMutableArray alloc] initWithCapacity:20];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LifeReferCell class] forCellWithReuseIdentifier:LifeReferCellIdentifier];
    
    self.tableView.tableHeaderView = self.collectionView;
    
    [self findShopTypeAll];
}

//取数方法
- (void)findShopTypeAll
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        
        //生成获取便民服务类型URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"0" forKey:@"classType"];
        NSString *findShopTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findShopType] params:param];
        
        [[AFOSCClient sharedClient]getPath:findShopTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           types = [Tool readJsonStrToShopTypeArray:operation.responseString];
                                        [self.collectionView reloadData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [types count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LifeReferCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LifeReferCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LifeReferCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[LifeReferCell class]]) {
                cell = (LifeReferCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    ShopType *type = [types objectAtIndex:row];
    if ([type.shopTypeId isEqualToString:@"-1"]) {
        cell.referNameLb.text = nil;
        return cell;
    }
    cell.referNameLb.text = type.shopTypeName;
    
    CGRect imageframe = cell.referIv.frame;
    imageframe.origin.y -= 2;
    cell.referIv.frame = imageframe;
    
    CGRect nameframe = cell.referNameLb.frame;
    nameframe.origin.y -= 4;
    cell.referNameLb.frame = nameframe;
    
    //图片显示及缓存
    if (type.imgData) {
        cell.referIv.image = type.imgData;
    }
    else
    {
        if ([type.imgUrlFull isEqualToString:@""]) {
            type.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:type.imgUrlFull]];
            if (imageData) {
                type.imgData = [UIImage imageWithData:imageData];
                cell.referIv.image = type.imgData;
            }
            else
            {
                IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = type.imgUrlFull;
                    record.url = urlStr;
                    [self startIconDownload:record forIndexPath:indexPath];
                }
            }
        }
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(79, 79);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopType *shopType = [types objectAtIndex:[indexPath row]];
    if (shopType != nil) {
        if ([shopType.shopTypeId isEqualToString:@"-1"]) {
            return;
        }
        self.typeId = shopType.shopTypeId;
        isLoadOver = NO;
        [self reload:NO];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma 下载图片
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}

- (void)appImageDidLoad:(NSString *)index
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:index];
    if (iconDownloader)
    {
        int _index = [index intValue];
        if (_index >= [types count]) {
            return;
        }
        ShopType *type = [types objectAtIndex:[index intValue]];
        if (type) {
            type.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(type.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:type.imgUrlFull]];
            [self.collectionView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (ShopType *type in types) {
        type.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [types removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    types = nil;
    _iconCache = nil;
    
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [shops removeAllObjects];
    shops = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(_locService == nil)
    {
        _locService = [[BMKLocationService alloc] init];
        _locService.delegate = self;
        [self startLocation];
    }
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    latitude = 0.0;
    longitude = 0.0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self reload:YES];
}

-(void)startLocation
{
    NSLog(@"进入定位");
    [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
    [_locService startUserLocationService];
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D mycoord = userLocation.location.coordinate;
    myPoint = BMKMapPointForCoordinate(mycoord);
    //    如果经纬度大于0表单表示定位成功，停止定位
    if (mycoord.latitude > 0) {
        latitude = mycoord.latitude;
        longitude = mycoord.longitude;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self reload:YES];
        [_locService stopUserLocationService];
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

- (void)refreshed:(NSNotification *)notification
{
    if (notification.object) {
        if ([(NSString *)notification.object isEqualToString:@"0"]) {
            [self.tableView setContentOffset:CGPointMake(0, -75) animated:YES];
            [self performSelector:@selector(doneManualRefresh) withObject:nil afterDelay:0.4];
        }
    }
}

- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.tableView];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

- (void)clear
{
    allCount = 0;
    [shops removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        
        //生成获取商家列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"0" forKey:@"stateId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        if (self.typeId != nil && [self.typeId length] > 0) {
            [param setValue:self.typeId forKey:@"shopTypeId"];
        }
        else
        {
            [param setValue:@"0" forKey:@"classType"];
            
        }
        if(latitude > 0)
        {
            [param setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
            [param setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
        }
        
        NSString *getShopListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findShopInfoByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:getShopListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSMutableArray *shopNews = [Tool readJsonStrToShopInfoArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       @try {
                                           int count = [shopNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [shops addObjectsFromArray:shopNews];
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           if (hud != nil) {
                                               [hud hide:YES];
                                           }
                                           [self doneLoadingTableViewData];
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"列表获取出错");
                                       //如果是刷新
                                       [self doneLoadingTableViewData];
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       isLoading = NO;
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
        isLoading = YES;
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return shops.count == 0 ? 1 : shops.count;
        }
        else
            return shops.count + 1;
    }
    else
        return shops.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [shops count])
    {
        return 116.0;
    }
    else
    {
        return 47.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([shops count] > 0) {
        if (row < [shops count])
        {
            ShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ShopInfoCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShopInfoCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[ShopInfoCell class]]) {
                        cell = (ShopInfoCell *)o;
                        break;
                    }
                }
            }
            ShopInfo *shop = [shops objectAtIndex:row];
            cell.shopNameLb.text = shop.shopName;
            cell.shopAddressLb.text = [NSString stringWithFormat:@"地址:%@", shop.shopAddress];
            cell.shopPhoneLb.text = [NSString stringWithFormat:@"电话:%@", shop.phone];
            
            if(shop.distance > 0)
            {
                cell.distanceView.hidden = NO;
                cell.distanceLb.text = [NSString stringWithFormat:@"%.2f千米", shop.distance];
            }
            else
            {
                cell.distanceView.hidden = YES;
            }
            
            [cell.imageIv setImageWithURL:[NSURL URLWithString:shop.imgUrlFull] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
            
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [shops count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        //        News *n = [news objectAtIndex:[indexPath row]];
        //        if (n) {
        //            NewsDetailView *newsDetail = [[NewsDetailView alloc] init];
        //            newsDetail.news = n;
        //            newsDetail.catalog = catalog;
        //            [self.navigationController pushViewController:newsDetail animated:YES];
        //        }
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
        [self performSelector:@selector(reload:)];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

@end
