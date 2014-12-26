//
//  PopularityView.m
//  BBK
//
//  Created by Seven on 14-12-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PopularityView.h"
#import "NoticeNewCell.h"
#import "CircleOfFriendsFullCell.h"
#import "UIImageView+WebCache.h"
#import "CircleOfFriendsPublishView.h"
#import "IQKeyboardManager/KeyboardManager.framework/Headers/IQKeyboardManager.h"
#import "ModifyUserInfoView.h"

@interface PopularityView ()

@property(nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) IBOutlet UITextField *textField;
@property(nonatomic, strong) IBOutlet UITextField *textFieldOnToolbar;
@property(nonatomic, strong) IBOutlet UIAlertView *deleteAlert;
@property(nonatomic, strong) IBOutlet UIAlertView *publishAlert;

@end

@implementation PopularityView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"人气榜";
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
    
    UILabel *headerView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    headerView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.tableView.tableHeaderView = headerView;
    
    self.textField.inputAccessoryView = [self keyboardToolBar];
}

- (void)textFieldBecomeFirstResponder
{
    [self.textFieldOnToolbar becomeFirstResponder];
    [self.textField becomeFirstResponder];
}

- (void)doneClicked:(id)sender
{
    [self.textField resignFirstResponder];
    [self.textFieldOnToolbar resignFirstResponder];
    NSString *replyContent = self.textFieldOnToolbar.text;
    if ([replyContent length] == 0) {
        return;
    }
    TopicFull *topic = [topics objectAtIndex:selectRow];
    if (topic)
    {
        //如果有网络连接
        if ([UserModel Instance].isNetworkRunning) {
            
            UserInfo *userInfo = [[UserModel Instance] getUserInfo];
            //查询当前有效的活动列表
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setValue:topic.topicId forKey:@"topicId"];
            [param setValue:userInfo.regUserId forKey:@"regUserId"];
            [param setValue:replyContent forKey:@"replyContent"];
            NSString *replyTopicSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addTopicReply] params:param];
            
            [param setValue:Appkey forKey:@"accessId"];
            [param setValue:replyTopicSign forKey:@"sign"];
            
            NSString *replyTopicUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addTopicReply];
            [[AFOSCClient sharedClient] postPath:replyTopicUrl parameters:param
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
                                                 }
                                                 else
                                                 {
                                                     self.textFieldOnToolbar.text = @"";
                                                     [self.textFieldOnToolbar resignFirstResponder];
                                                     [self.textField resignFirstResponder];
                                                     
                                                     UserInfo *userInfo = [[UserModel Instance] getUserInfo];
                                                     
                                                     TopicReply *reply = [[TopicReply alloc] init];
                                                     reply.replyContent = [NSString stringWithFormat:@"%@：%@",userInfo.nickName, replyContent];
                                                     reply.contentHeight = [Tool heightForString:reply.replyContent fontSize:14.0 andWidth:232.0] + 3;
                                                     topic.replyHeight += reply.contentHeight;
                                                     topic.viewAddHeight +=  reply.contentHeight;
                                                     
                                                     reply.replyContentAttr = [[NSMutableAttributedString alloc] initWithString:reply.replyContent];
                                                     [reply.replyContentAttr addAttribute:NSForegroundColorAttributeName value:[Tool getColorForMain] range:NSMakeRange(0, [userInfo.nickName length] + 1)];
                                                     
                                                     [topic.replyList addObject:reply];
                                                     
                                                     NSIndexPath *rowIndex=[NSIndexPath indexPathForRow:selectRow inSection:0];
                                                     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:rowIndex,nil] withRowAnimation:UITableViewRowAnimationMiddle];
                                                 }
                                                 
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
    doneButton.title = @"回复";
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
        
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        
        //生成获取朋友圈列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:userInfo.defaultUserHouse.regUserId forKey:@"userId"];
        [param setValue:@"replyCount-desc" forKey:@"sort"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:@"0" forKey:@"stateId"];
        NSString *topicInfoByPageUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findTopicInfoByPageForApp] params:param];
        
        [[AFOSCClient sharedClient]getPath:topicInfoByPageUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *topicNews = [Tool readJsonStrToTopicFullArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
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
            if(topic.viewAddHeight - 30 <= 10)
            {
                return 141 + topic.viewAddHeight - 40;
            }
            else
            {
                return 141 + topic.viewAddHeight - 50;
            }
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
            
            UserInfo *userInfo = [[UserModel Instance] getUserInfo];
            
            if ([topic.regUserId isEqualToString:userInfo.regUserId]) {
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
                //加载图片
                cell.navigationController = self.navigationController;
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
                
                UserInfo *userInfo = [[UserModel Instance] getUserInfo];
                //查询点赞/取消点赞
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:topic.topicId forKey:@"topicId"];
                [param setValue:userInfo.regUserId forKey:@"userId"];
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
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    if ([userInfo.nickName length] == 0) {
        if (self.publishAlert == nil) {
            self.publishAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还没完善您的昵称\n填写昵称后才能发布朋友圈！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        }
        [self.publishAlert show];
        return;
    }
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        selectRow = tap.tag;
        [self.textField becomeFirstResponder];
    }
}

- (void)deteleAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    self.deleteAlert = [[UIAlertView alloc] initWithTitle:@"朋友圈删除"
                                                  message:@"你确定要删除这条朋友圈消息"
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"删除", nil];
    self.deleteAlert.tag = tap.tag;
    [self.deleteAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.deleteAlert) {
        if (buttonIndex == 1) {
            TopicFull *topic = [topics objectAtIndex:alertView.tag];
            if (topic)
            {
                //如果有网络连接
                if ([UserModel Instance].isNetworkRunning) {
                    //删除社区朋友圈
                    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                    [param setValue:topic.topicId forKey:@"topicId"];
                    NSString *topicHeartUrl =  [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_delTopicInfo] params:param];
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
                                                           
                                                       }
                                                       else
                                                       {
                                                           [topics removeObject:topic];
                                                           [self.tableView reloadData];
                                                       }
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
    if (alertView == self.publishAlert) {
        ModifyUserInfoView *modifyView = [[ModifyUserInfoView alloc] init];
        modifyView.parentView = self.view;
        modifyView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:modifyView animated:YES];
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
        [self.textField resignFirstResponder];
        [self.textFieldOnToolbar resignFirstResponder];
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
