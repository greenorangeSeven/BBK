//
//  CallServiceView.m
//  BBK
//
//  Created by Seven on 14-12-3.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "CallServiceView.h"
#import "CallService.h"
#import "CallServiceCell.h"
#import "CallServiceReusable.h"

@interface CallServiceView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation CallServiceView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物业呼叫";
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
    [self.collectionView registerClass:[CallServiceCell class] forCellWithReuseIdentifier:CallServiceCellIdentifier];
    [self.collectionView registerClass:[CallServiceReusable class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CallServiceHead"];
    
    [self reload];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSString *getCallServiceListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_callService] params:nil];
        
        [[AFOSCClient sharedClient]getPath:getCallServiceListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           services = [Tool readJsonStrToServiceArray:operation.responseString];
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
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [services count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CallServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CallServiceCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CallServiceCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[CallServiceCell class]]) {
                cell = (CallServiceCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    CallService *service = [services objectAtIndex:row];
    if (row % 2 != 0) {
        CGRect frame = cell.boxView.frame;
        frame.origin.x = 5;
        cell.boxView.frame = frame;
    }
    [Tool roundTextView:cell.boxView andBorderWidth:0.5 andCornerRadius:5.0];
    cell.serviceNameLb.text = service.departmentName;
    cell.servicePhoneLb.text = service.departmentPhone;
    
    //图片显示及缓存
    if (service.imgData) {
        cell.servicePicIv.image = service.imgData;
    }
    else
    {
        if ([service.departmentPic isEqualToString:@""]) {
            service.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:service.departmentPic]];
            if (imageData) {
                service.imgData = [UIImage imageWithData:imageData];
                cell.servicePicIv.image = service.imgData;
            }
            else
            {
                IconDownloader *downloader = [self.imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = service.departmentPic;
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
    return CGSizeMake(155, 145);
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
    CallService *project = [services objectAtIndex:[indexPath row]];
    if (project != nil) {
        NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", project.departmentPhone]];
        if (!phoneWebView) {
            phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        }
        [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
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
        if (_index >= [services count]) {
            return;
        }
        CallService *service = [services objectAtIndex:[index intValue]];
        if (service) {
            service.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(service.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:service.departmentPic]];
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
    for (CallService *service in services) {
        service.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [services removeAllObjects];
    [self.imageDownloadsInProgress removeAllObjects];
    services = nil;
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
    if (kind == UICollectionElementKindSectionHeader){
        CallServiceReusable *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CallServiceHead" forIndexPath:indexPath];
        reusableview = headerView;
    }
    return reusableview;
}

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", servicephone]];
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