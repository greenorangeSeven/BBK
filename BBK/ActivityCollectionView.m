//
//  ActivityCollectionView.m
//  NewWorld
//
//  Created by Seven on 14-7-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ActivityCollectionView.h"
#import "UIImageView+WebCache.h"
#import "Activity.h"
#import "ActivityCollectionCell.h"
#import "ActivityDetailView.h"

@interface ActivityCollectionView ()

@end

@implementation ActivityCollectionView

@synthesize activityCollection;
@synthesize pageControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"社区活动";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.activityCollection.delegate = self;
    self.activityCollection.dataSource = self;
    
    [self.activityCollection registerClass:[ActivityCollectionCell class] forCellWithReuseIdentifier:ActivityCollectionCellIdentifier];
    
    
    self.activityCollection.backgroundColor = [Tool getBackgroundColor];
    [self getActivityList];
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

//取数方法
- (void)getActivityList
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //查询当前有效的活动列表
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        NSString *getActivityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCellActivityOnTime] params:param];
        [[AFOSCClient sharedClient]getPath:getActivityListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           activities = [Tool readJsonStrToActivityArray:operation.responseString];
                                           self.pageControl.numberOfPages = [activities count];
                                           [self.activityCollection reloadData];
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
    return [activities count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ActivityCollectionCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCollectionCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ActivityCollectionCell class]]) {
                cell = (ActivityCollectionCell *)o;
                break;
            }
        }
    }
    int indexRow = [indexPath row];
    Activity *activity = [activities objectAtIndex:indexRow];
    self.pageControl.currentPage = indexRow;
    
    [Tool roundView:cell.bg andCornerRadius:5.0f];
    
    [cell.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", activity.heartCount] forState:UIControlStateNormal];
    
    [cell.attendBtn addTarget:self action:@selector(attendAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.attendBtn.tag = indexRow;
    
    [cell.checkDetailBtn addTarget:self action:@selector(checkDetailAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkDetailBtn.tag = indexRow;
    
    cell.titleLb.text = activity.activityName;
    cell.dateLb.text = [NSString stringWithFormat:@"活动时间：%@-%@", activity.starttime, activity.endtime];
    cell.conditionLb.text = [NSString stringWithFormat:@"活动资格：%@", activity.qualifications];
    cell.telephoneLb.text = [NSString stringWithFormat:@"咨询电话：%@", activity.phone];
    cell.qqLb.text = [NSString stringWithFormat:@"咨询QQ：%@", activity.qq];
    [cell.imageIv setImageWithURL:[NSURL URLWithString:activity.imgUrlFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    return cell;
}

- (void)attendAction:(id)sender
{

}

- (void)checkDetailAction:(id)sender
{
        UIButton *tap = (UIButton *)sender;
        if (tap) {
            Activity *activity = [activities objectAtIndex:tap.tag];
            if (activity)
            {
                ActivityDetailView *activityDetail = [[ActivityDetailView alloc] init];
                NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_activityDetail ,activity.activityId];
                activityDetail.titleStr = @"社区活动";
                activityDetail.urlStr = pushDetailHtm;
                [self.navigationController pushViewController:activityDetail animated:YES];
            }
        }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return CGSizeMake(320, 504);
    }
    else
    {
        return CGSizeMake(320, 416);
    }
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
    Activity *activity = [activities objectAtIndex:[indexPath row]];
    if (activity)
    {
        ActivityDetailView *activityDetail = [[ActivityDetailView alloc] init];
        NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_activityDetail ,activity.activityId];
        activityDetail.titleStr = @"社区活动";
        activityDetail.urlStr = pushDetailHtm;
        [self.navigationController pushViewController:activityDetail animated:YES];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)viewDidUnload {
    [self setActivityCollection:nil];
    [activities removeAllObjects];
    activities = nil;
    [super viewDidUnload];
}

@end
