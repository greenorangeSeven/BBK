//
//  GoodBorrowView.m
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "GoodBorrowView.h"
#import "GoodBorrowCell.h"
#import "BorrowGoodFromView.h"
#import "BorrowRecordCell.h"

@interface GoodBorrowView ()
{
    UIWebView *phoneWebView;
    NSMutableArray *goods;
    NSMutableArray *borrowRecords;
    TQImageCache * _iconCache;
    MBProgressHUD *hud;
}

@end

@implementation GoodBorrowView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物品借用";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[GoodBorrowCell class] forCellWithReuseIdentifier:GoodBorrowCellIdentifier];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    
    [self refreshGoodsData];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)refreshGoodsData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        //生成获取物业物品URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"40" forKey:@"countPerPages"];
        
        NSString *getCircleOfFriendsListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_BorrowGoods] params:param];
        
        [[AFOSCClient sharedClient]getPath:getCircleOfFriendsListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           [goods removeAllObjects];
                                           goods = [Tool readJsonStrToBorrowGoodsArray:operation.responseString];
                                           if (goods != nil) {
                                               int goodsCount = [goods count];
                                               int goodsRow = 0;
                                               if (goodsCount > 0) {
                                                   goodsRow = goodsCount / 3;
                                                   if (goodsCount % 3 > 0) {
                                                       goodsRow += 1;
                                                   }
                                                   
                                                   //计算各控件的高度
                                                   CGRect frame = self.collectionView.frame;
                                                   float addHeight =frame.size.height * (goodsRow - 1);
                                                   frame.size.height = frame.size.height * goodsRow;
                                                   self.collectionView.frame = frame;
                                                   
                                                   CGRect headFrame = self.headView.frame;
                                                   headFrame.size.height = headFrame.size.height + addHeight;
                                                   self.headView.frame = headFrame;
//                                                   self.headView.hidden =YES;
                                                   self.tableView.tableHeaderView = self.headView;
                                                   [self findBorrowRecords];
                                               }
                                               else
                                               {
                                                   CGRect frame = self.collectionView.frame;
                                                   frame.size.height = 0;
                                                   self.collectionView.frame = frame;
                                               }
                                               [self.collectionView reloadData];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           if (hud != nil) {
                                               [hud hide:YES];
                                           }
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

- (void)findBorrowRecords
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        //查询指定用户的物品借用记录URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        
        NSString *findBorrowRecordsUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBorrowRecordsByUserId] params:param];
        [[AFOSCClient sharedClient]getPath:findBorrowRecordsUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           [borrowRecords removeAllObjects];
                                           borrowRecords = [Tool readJsonStrToBorrowRecordsArray:operation.responseString];
                                           [self.tableView reloadData];
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

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [goods count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodBorrowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GoodBorrowCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GoodBorrowCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[GoodBorrowCell class]]) {
                cell = (GoodBorrowCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    BorrowGood *good = [goods objectAtIndex:row];
    if (row % 3 == 0) {
        CGRect frame = cell.frameView.frame;
        frame.origin.x = 16;
        cell.frameView.frame = frame;
    }
    else if (row % 3 == 1) {
        CGRect frame = cell.frameView.frame;
        frame.origin.x = 8;
        cell.frameView.frame = frame;
    }
    else if (row % 3 == 2) {
        CGRect frame = cell.frameView.frame;
        frame.origin.x = 0;
        cell.frameView.frame = frame;
    }
    [Tool roundTextView:cell.frameView andBorderWidth:0.5 andCornerRadius:5.0];
    cell.goodNameLb.text = good.goodsName;
    cell.goodNumberLb.text = [NSString stringWithFormat:@"剩余%d件", [good.goodsNum intValue] - [good.borrowCount intValue]];
    
    //图片显示及缓存
    if (good.imgData) {
        cell.goodPicIv.image = good.imgData;
    }
    else
    {
        if ([good.imgUrlFull isEqualToString:@""]) {
            good.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:good.imgUrlFull]];
            if (imageData) {
                good.imgData = [UIImage imageWithData:imageData];
                cell.goodPicIv.image = good.imgData;
            }
            else
            {
                IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = good.imgUrlFull;
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
    return CGSizeMake(100, 100);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 0, 5, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BorrowGood *good = [goods objectAtIndex:[indexPath row]];
    if (good != nil) {
        BorrowGoodFromView *borrowGood = [[BorrowGoodFromView alloc] init];
        borrowGood.good = good;
        borrowGood.parentView = self.view;
        borrowGood.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:borrowGood animated:YES];
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
        if (_index >= [goods count]) {
            return;
        }
        BorrowGood *good = [goods objectAtIndex:[index intValue]];
        if (good) {
            good.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(good.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:good.imgUrlFull]];
            [self.collectionView reloadData];
        }
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return borrowRecords.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BorrowRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:BorrowRecordCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BorrowRecordCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[BorrowRecordCell class]]) {
                cell = (BorrowRecordCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    BorrowRecord *record = [borrowRecords objectAtIndex:row];
    
    if (record.starttime.length > 0 && record.userId.length == 0) {
        cell.stateNameLb.text = @"发起申请";
        cell.stateNameLb.textColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
        cell.imageIv.image = [UIImage imageNamed:@"borrow_black"];
        cell.infoLb.text = [NSString stringWithFormat:@"%@  %@  %d件", record.starttime, record.goodsName, record.borrowNum];
    }
    else if (record.starttime.length > 0 && record.userId.length > 0 && record.endtime.length == 0)
    {
        cell.stateNameLb.text = @"未归还";
        cell.imageIv.image = [UIImage imageNamed:@"borrow_orange"];
        cell.stateNameLb.textColor = [Tool getColorForMain];
        NSMutableAttributedString *borrowInfo = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@  %d件", record.starttime, record.goodsName, record.borrowNum]];
        [borrowInfo addAttribute:NSForegroundColorAttributeName value:[Tool getColorForMain] range:NSMakeRange(record.starttime.length + 2,record.goodsName.length)];
        cell.infoLb.attributedText = borrowInfo;
    }
    else if (record.starttime.length > 0 && record.userId.length > 0 && record.endtime.length > 0)
    {
        cell.stateNameLb.text = @"已归还";
        cell.imageIv.image = [UIImage imageNamed:@"borrow_black"];
        cell.stateNameLb.textColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
        cell.infoLb.text = [NSString stringWithFormat:@"%@  %@  %d件", record.starttime, record.goodsName, record.borrowNum];
    }
    
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (BorrowGood *good in goods) {
        good.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [goods removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    goods = nil;
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

- (IBAction)telAction:(id)sender
{
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
