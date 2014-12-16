//
//  ConvenienceTypeView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ConvenienceTypeView.h"
#import "LifeReferCell.h"
#import "ConvenienceTableView.h"

@interface ConvenienceTypeView ()

@end

@implementation ConvenienceTypeView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"便民服务";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LifeReferCell class] forCellWithReuseIdentifier:LifeReferCellIdentifier];
    [self findShopTypeAll];
}

//取数方法
- (void)findShopTypeAll
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取便民服务类型URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1" forKey:@"classType"];
        NSString *findShopTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findShopType] params:param];
        
        [[AFOSCClient sharedClient]getPath:findShopTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           types = [Tool readJsonStrToShopTypeArray:operation.responseString];
                                           int n = [types count] % 4;
                                           if(n > 0)
                                           {
                                               for (int i = 0; i < 4 - n; i++) {
                                                   ShopType *r = [[ShopType alloc] init];
                                                   r.shopTypeId = @"-1";
                                                   [types addObject:r];
                                               }
                                           }
                                           [self.collectionView reloadData];
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
        cell.referIv.image = nil;
        return cell;
    }
    cell.referNameLb.text = type.shopTypeName;
    
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
    return CGSizeMake(79, 90);
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
        ConvenienceTableView *shopTableView = [[ConvenienceTableView alloc] init];
        shopTableView.type = shopType;
        [self.navigationController pushViewController:shopTableView animated:YES];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
