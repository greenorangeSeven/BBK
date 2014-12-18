//
//  CircleOfFriendsView.m
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "CircleOfFriendsView.h"
#import "NoticeNewCell.h"
#import "CircleOfFriendsFullCell.h"
#import "UIImageView+WebCache.h"

@interface CircleOfFriendsView ()

@end

@implementation CircleOfFriendsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"社区朋友圈";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
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
    
    topics = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [topics removeAllObjects];
    topics = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [topics removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        
        //生成获取朋友圈列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"cellId"] forKey:@"cellId"];
        [param setValue:[[UserModel Instance] getUserValueForKey:@"regUserId"] forKey:@"userId"];
        [param setValue:@"starttime-desc" forKey:@"sort"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        NSString *topicInfoByPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findTopicInfoByPageForApp] params:param];
        
        [[AFOSCClient sharedClient]getPath:topicInfoByPageUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *noticeNews = [Tool readJsonStrToTopicFullArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           int count = [noticeNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [topics addObjectsFromArray:noticeNews];
                                           [self.tableView reloadData];
                                           [self doneLoadingTableViewData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
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
        int row = [indexPath row];
        TopicFull *topic = [topics objectAtIndex:row];
        if (topic.viewAddHeight - 30 > 0)
        {
            return 151 + topic.viewAddHeight - 60;
        }
        else
        {
            return 141.0;
        }
    }
    else
    {
        return 50.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([topics count] > 0) {
        if (row < [topics count])
        {
            
            CircleOfFriendsFullCell *cell = [tableView dequeueReusableCellWithIdentifier:CircleOfFriendsFullCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CircleOfFriendsFullCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[CircleOfFriendsFullCell class]]) {
                        cell = (CircleOfFriendsFullCell *)o;
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
            
            TopicFull *topic = [topics objectAtIndex:row];
            cell.nickNameLb.text = topic.nickName;
            cell.timeLb.text = topic.starttime;
            cell.contentLb.text = topic.content;
            
            //计算话题内容高度
            CGRect contentFrame = cell.contentLb.frame;
            contentFrame.size.height = topic.contentHeight;
            cell.contentLb.frame = contentFrame;
            
            //计算图片区域高度
            CGRect imgFrame = cell.collectionView.frame;
            imgFrame.origin.y = contentFrame.origin.y + contentFrame.size.height;
            imgFrame.size.height = topic.imageViewHeight;
            cell.collectionView.frame = imgFrame;
            
            //计算评论区域高度
            CGRect replyFrame = cell.replyView.frame;
            replyFrame.origin.y = imgFrame.origin.y + imgFrame.size.height + 3;
            replyFrame.size.height = topic.replyHeight;
            cell.replyView.frame = replyFrame;
            
            //计算评论区域高度
            CGRect tableFrame = cell.tableView.frame;
            tableFrame.size.height = replyFrame.size.height;
            cell.tableView.frame = tableFrame;
            
            //计算按钮区域高度
            CGRect buttomFrame = cell.buttomView.frame;
            buttomFrame.origin.y = replyFrame.origin.y + replyFrame.size.height + 5;
            if(buttomFrame.origin.y < 83)
            {
                buttomFrame.origin.y = 83;
            }
            cell.buttomView.frame = buttomFrame;
            
            //计算框架View的高度
            CGRect boxFrame = cell.boxView.frame;
            boxFrame.size.height = buttomFrame.origin.y + buttomFrame.size.height + 2;
            cell.boxView.frame = boxFrame;
            
            if ([topic.imgUrlList count] > 0) {
                [cell loadCircleOfFriendsImage:topic];
                cell.collectionView.hidden = NO;
            }
            else
            {
                cell.collectionView.hidden = YES;
            }
            
            if ([topic.replyList count] > 0) {
                [cell loadCircleOfFriendsReply:topic];
                cell.replyView.hidden = NO;
            }
            else
            {
                cell.replyView.hidden = YES;
            }
            
            [cell.userFaceIv setImageWithURL:[NSURL URLWithString:topic.photoFull] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
            
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
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
