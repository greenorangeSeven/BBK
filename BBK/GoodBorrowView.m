//
//  GoodBorrowView.m
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "GoodBorrowView.h"
#import "GoodBorrowCell.h"

@interface GoodBorrowView ()
{
    UIWebView *phoneWebView;
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
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[GoodBorrowCell class] forCellWithReuseIdentifier:GoodBorrowCellIdentifier];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    
    [self refreshGoodsData];
}

- (void)refreshGoodsData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取物业物品URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
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
                                                   
                                                   self.tableView.tableHeaderView = self.headView;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 300;
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
//        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", project.departmentPhone]];
//        if (!phoneWebView) {
//            phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
//        }
//        [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
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
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[UserModel Instance] getUserValueForKey:@"cellPhone"]]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
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
