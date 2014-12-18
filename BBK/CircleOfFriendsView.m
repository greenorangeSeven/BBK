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
#import "IQKeyboardManager/KeyboardManager.framework/Headers/IQKeyboardManager.h"

@interface CircleOfFriendsView ()

@property(nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) IBOutlet UITextField *textField;
@property(nonatomic, strong) IBOutlet UITextField *textFieldOnToolbar;

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
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(-10, 0, 0, 0)];
    [self.tableView addSubview:self.textField];
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    self.textFieldOnToolbar.delegate = self;
    
    self.textField.inputAccessoryView = [self keyboardToolBar];
}

- (void)textFieldBecomeFirstResponder
{
    [self.textFieldOnToolbar becomeFirstResponder];
    [self.textField resignFirstResponder];
}

- (void)doneClicked:(id)sender
{
    [self.textField resignFirstResponder];
    [self.textFieldOnToolbar resignFirstResponder];
}

- (UIToolbar *)keyboardToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar sizeToFit];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 4, 250, 32)];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textFieldOnToolbar = textField;
    self.textFieldOnToolbar.returnKeyType = UIReturnKeyDone;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:textField];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] init];
    doneButton.title = @"评论";
    doneButton.style = UIBarButtonItemStyleDone;
    doneButton.action = @selector(doneClicked:);
    doneButton.target = self;
    
    [toolBar setItems:@[item,doneButton]];
    
    return toolBar;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFieldOnToolbar resignFirstResponder];
    [self.textField resignFirstResponder];
    return YES;
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
                                       
                                       NSMutableArray *topicNews = [Tool readJsonStrToTopicFullArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *topicJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           int totalRecord = [[[topicJsonDic objectForKey:@"data"] objectForKey:@"totalRecord"] intValue];
                                           self.recordNumLb.text = [NSString stringWithFormat:@"共%d条朋友圈动态", totalRecord];
                                           
                                           int count = [topicNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [topics addObjectsFromArray:topicNews];
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
            
            cell.typeNameLb.text = [NSString stringWithFormat:@"【%@】", topic.typeName];
            
            if ([topic.regUserId isEqualToString:[[UserModel Instance] getUserValueForKey:@"regUserId"]]) {
                cell.deleteBtn.hidden = NO;
            }
            else
            {
                cell.deleteBtn.hidden = YES;
            }
            
            [cell.deleteBtn addTarget:self action:@selector(deteleAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.deleteBtn.tag = row;
            
            [cell.heartBtn setTitle:[NSString stringWithFormat:@" 赞(%d)", topic.heartCount] forState:UIControlStateNormal];
            [cell.heartBtn addTarget:self action:@selector(topicHeartAction:) forControlEvents:UIControlEventTouchUpInside];
            if (topic.isHeart == 1) {
                [cell.heartBtn setImage:[UIImage imageNamed:@"heart_orange"] forState:UIControlStateNormal];
            }
            else
            {
                [cell.heartBtn setImage:[UIImage imageNamed:@"heart_gray"] forState:UIControlStateNormal];
            }
            
            cell.heartBtn.tag = row;
            
            [cell.replyBtn addTarget:self action:@selector(replyAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.replyBtn.tag = row;
            
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
            
            [cell.userFaceIv setImageWithURL:[NSURL URLWithString:topic.photoFull] placeholderImage:[UIImage imageNamed:@"default_head"]];
            
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

- (void)topicHeartAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    
    if (tap) {
        TopicFull *topic = [topics objectAtIndex:tap.tag];
        if (topic)
        {
            tap.enabled = NO;
            //如果有网络连接
            if ([UserModel Instance].isNetworkRunning) {
                //查询当前有效的活动列表
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:topic.topicId forKey:@"topicId"];
                [param setValue:[[UserModel Instance] getUserValueForKey:@"regUserId"] forKey:@"userId"];
                NSString *topicHeartUrl = @"";
                if (topic.isHeart == 1) {
                    topicHeartUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_delTopicHeart] params:param];
                }
                else
                {
                    topicHeartUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addTopicHeart] params:param];
                }
                [[AFOSCClient sharedClient]getPath:topicHeartUrl parameters:Nil
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               @try {
                                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSError *error;
                                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                   
                                                   NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                                   if ([state isEqualToString:@"0000"] == NO) {
                                                       UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                                    message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"确定"
                                                                                          otherButtonTitles:nil];
                                                       [av show];
                                                       //                                                       return;
                                                   }
                                                   else
                                                   {
                                                       //                                                       [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                                       if (topic.isHeart == 1) {
                                                           topic.heartCount -= 1;
                                                           [tap setImage:[UIImage imageNamed:@"heart_gray"] forState:UIControlStateNormal];
                                                           topic.isHeart = 0;
                                                       }
                                                       else
                                                       {
                                                           topic.heartCount += 1;
                                                           [tap setImage:[UIImage imageNamed:@"heart_orange"] forState:UIControlStateNormal];
                                                           topic.isHeart = 1;
                                                       }
                                                       [self.tableView reloadData];
                                                   }
                                                   tap.enabled = YES;
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
    }
}

- (void)replyAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        TopicFull *topic = [topics objectAtIndex:tap.tag];
        [self.textField becomeFirstResponder];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textField resignFirstResponder];
    [self.textFieldOnToolbar resignFirstResponder];
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
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

@end
