//
//  LifePageView.m
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "LifePageView.h"
#import "CircleOfFriendsCell.h"
#import "LifeReferView.h"
#import "ConvenienceTypeView.h"
#import "ShopTypeView.h"
#import "MonthlyView.h"

@interface LifePageView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation LifePageView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"社区生活";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-33);
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
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
    
    topics = [[NSMutableArray alloc] initWithCapacity:2];
    [self getADVData];
    [self refreshCircleOfFriendsData:YES];
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141793407977800" forKey:@"typeId"];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           advDatas = [Tool readJsonStrToAdinfoArray:operation.responseString];
                                           int length = [advDatas count];
                                           
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:length-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:i];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:0];
                                               [itemArray addObject:item];
                                           }
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 135) delegate:self imageItems:itemArray isAuto:YES];
                                           [bannerView scrollToIndex:0];
                                           [self.advIv addSubview:bannerView];
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

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:advIndex];
    if (adv)
    {
        //        ADVDetailView *advDetail = [[ADVDetailView alloc] init];
        //        advDetail.hidesBottomBarWhenPushed = YES;
        //        advDetail.adv = adv;
        //        [self.navigationController pushViewController:advDetail animated:YES];
    }
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    advIndex = index;
}

- (void)clear
{
    allCount = 0;
    [self.imageDownloadsInProgress removeAllObjects];
    [topics removeAllObjects];
    isLoadOver = NO;
}

- (void)refreshCircleOfFriendsData:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        
        //生成获取社区朋友圈URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"2" forKey:@"countPerPages"];
        [param setValue:@"0" forKey:@"stateId"];
        
        NSString *getCircleOfFriendsListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_CircleOfFriends] params:param];
        
        [[AFOSCClient sharedClient]getPath:getCircleOfFriendsListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       NSMutableArray *topicsNews = [Tool readJsonStrToTopicArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       @try {
                                           int count = [topicsNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [topics addObjectsFromArray:topicsNews];
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                           
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"列表获取出错");
                                       
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
        
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return topics.count == 0 ? 1 : topics.count;
        }
        else
            return topics.count + 1;
    }
    else
        return topics.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [topics count]) {
        //出现异常问题暂时最后一条就加高行高
        if (row == [topics count] -1) {
            int row = [indexPath row];
            Topic *topic = [topics objectAtIndex:row];
            return 140.0 + topic.viewAddHeight;
        }
        else
        {
            int row = [indexPath row];
            Topic *topic = [topics objectAtIndex:row];
            return 120.0 + topic.viewAddHeight;
        }
    }
    else
    {
        return 40.0;
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
    if ([topics count] > 0) {
        if (row < [topics count])
        {
            
            CircleOfFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CircleOfFriendsCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CircleOfFriendsCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[CircleOfFriendsCell class]]) {
                        cell = (CircleOfFriendsCell *)o;
                        break;
                    }
                }
            }
            [Tool roundTextView:cell.boxView andBorderWidth:0.5 andCornerRadius:5.0];
            //图片圆形处理
            cell.userFaceIv.layer.masksToBounds = YES;
            cell.userFaceIv.layer.cornerRadius = cell.userFaceIv.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
            cell.userFaceIv.backgroundColor = [UIColor whiteColor];
            
            int row = [indexPath row];
            
            Topic *topic = [topics objectAtIndex:row];
            cell.nickNameLb.text = topic.nickName;
            cell.timeLb.text = topic.starttime;
            cell.contentLb.text = topic.content;
            
            //计算话题内容高度
            CGRect contentFrame = cell.contentLb.frame;
            contentFrame.size.height = topic.contentHeight;
            cell.contentLb.frame = contentFrame;
            
            //计算图片区域高度
            CGRect imgFrame = cell.collectionView.frame;
            imgFrame.origin.y = contentFrame.origin.y + contentFrame.size.height + 5;
            imgFrame.size.height = topic.imageViewHeight;
            cell.collectionView.frame = imgFrame;
            
            //计算框架View的高度
            CGRect boxFrame = cell.boxView.frame;
            boxFrame.size.height += topic.viewAddHeight;
            cell.boxView.frame = boxFrame;
            
            [cell loadCircleOfFriendsImage:topic];
            
            //图片显示及缓存
            if (topic.imgData) {
                cell.userFaceIv.image = topic.imgData;
            }
            else
            {
                if ([topic.photoFull isEqualToString:@""]) {
                    topic.imgData = [UIImage imageNamed:@"loadingpic2.png"];
                }
                else
                {
                    NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:topic.photoFull]];
                    if (imageData) {
                        topic.imgData = [UIImage imageWithData:imageData];
                        cell.userFaceIv.image = topic.imgData;
                    }
                    else
                    {
                        IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                        if (downloader == nil) {
                            ImgRecord *record = [ImgRecord new];
                            NSString *urlStr = topic.photoFull;
                            record.url = urlStr;
                            [self startIconDownload:record forIndexPath:indexPath];
                        }
                    }
                }
            }
            
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
    if (row >= [topics count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(refreshCircleOfFriendsData:)];
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
        [self performSelector:@selector(refreshCircleOfFriendsData:)];
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
        [self refreshCircleOfFriendsData:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
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
        if (_index >= [topics count]) {
            return;
        }
        Topic *topic = [topics objectAtIndex:[index intValue]];
        if (topic) {
            topic.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(topic.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:topic.photoFull]];
            [self.tableView reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Topic *topic in topics) {
        topic.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [topics removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    topics = nil;
    _iconCache = nil;
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
    bannerView.delegate = self;
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    bannerView.delegate = nil;
}

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[UserModel Instance] getUserValueForKey:@"cellPhone"]]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

//生活查询
- (IBAction)LifeReferAction:(id)sender {
    LifeReferView *lifeReferView = [[LifeReferView alloc] init];
    lifeReferView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lifeReferView animated:YES];
}

//便民服务
- (IBAction)convenienceTypeAction:(id)sender {
    ConvenienceTypeView *convenienceView = [[ConvenienceTypeView alloc] init];
    convenienceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:convenienceView animated:YES];
}

//周边商家
- (IBAction)ShopTypeAction:(id)sender {
    ShopTypeView *shopTypeView = [[ShopTypeView alloc] init];
    shopTypeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopTypeView animated:YES];
}

//悦月刊
- (IBAction)pushMonthlyViewAction:(id)sender {
    MonthlyView *monthlyView = [[MonthlyView alloc] init];
    monthlyView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:monthlyView animated:YES];
}

@end
