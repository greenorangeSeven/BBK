//
//  LifeReferView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "LifeReferView.h"
#import "LifeRefer.h"
#import "LifeReferCell.h"
#import "LifeReferFooterReusableView.h"
#import "CommDetailView.h"

@interface LifeReferView ()

@end

@implementation LifeReferView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"生活查询";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LifeReferCell class] forCellWithReuseIdentifier:LifeReferCellIdentifier];
    [self.collectionView registerClass:[LifeReferFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LifeReferFooter"];
    
    [self findLifeTypeAll];
}

//取数方法
- (void)findLifeTypeAll
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取生活查询URL
        NSString *findLifeTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findLifeTypeAll] params:nil];
        
        [[AFOSCClient sharedClient]getPath:findLifeTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           refers = [Tool readJsonStrToLifeReferArray:operation.responseString];
                                           int n = [refers count] % 4;
                                           if(n > 0)
                                           {
                                               for (int i = 0; i < 4 - n; i++) {
                                                   LifeRefer *r = [[LifeRefer alloc] init];
                                                   r.lifeTypeId = @"-1";
                                                   [refers addObject:r];
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
    return [refers count];
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
    LifeRefer *refer = [refers objectAtIndex:row];
    if ([refer.lifeTypeId isEqualToString:@"-1"]) {
        cell.referNameLb.text = nil;
        cell.referIv.image = nil;
        return cell;
    }
    cell.referNameLb.text = refer.lifeTypeName;
    
    //图片显示及缓存
    if (refer.imgData) {
        cell.referIv.image = refer.imgData;
    }
    else
    {
        if ([refer.imgUrlFull isEqualToString:@""]) {
            refer.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:refer.imgUrlFull]];
            if (imageData) {
                refer.imgData = [UIImage imageWithData:imageData];
                cell.referIv.image = refer.imgData;
            }
            else
            {
                IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = refer.imgUrlFull;
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
    LifeRefer *refer = [refers objectAtIndex:[indexPath row]];
    if (refer != nil) {
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = refer.lifeTypeName;
        detailView.urlStr = refer.url;
        [self.navigationController pushViewController:detailView animated:YES];
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
        if (_index >= [refers count]) {
            return;
        }
        LifeRefer *refer = [refers objectAtIndex:[index intValue]];
        if (refer) {
            refer.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(refer.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:refer.imgUrlFull]];
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
    for (LifeRefer *refer in refers) {
        refer.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [refers removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    refers = nil;
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

// 返回headview或footview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter){
        LifeReferFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LifeReferFooter" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
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
