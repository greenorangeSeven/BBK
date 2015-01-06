//
//  SuitDetailView.m
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "SuitDetailView.h"
#import "SuitBasicCell.h"
#import "SuitReplyCell.h"
#import "SuitResutCell.h"
#import "SuitReply.h"
#import "AMRatingControl.h"

@interface SuitDetailView ()
{
    MBProgressHUD *hud;
    NSMutableArray *detailItems;
    NSArray *suitResultArray;
    //如果suitStateId==2则为已评价
    int suitStateId;
}

@property (weak, nonatomic) UITextView *userRecontent;
@property (weak, nonatomic) UIButton *submitScoreBtn;

@end

@implementation SuitDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"投诉建议";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    if([self.present isEqualToString:@"present"] == YES)
    {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(closeAction)];
        leftBtn.tintColor = [Tool getColorForMain];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    
    //适配iOS7uinavigationbar遮挡的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getSuitDetailData];
}

- (void)closeAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)getSuitDetailData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取报修详情URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.suitWorkId forKey:@"suitWorkId"];
        NSString *getSuitDetailUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findSuitWorkDetail] params:param];
        
        [[AFOSCClient sharedClient]getPath:getSuitDetailUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [detailItems removeAllObjects];
                                       @try {
                                           detailItems = [Tool readJsonStrToSuitItemArray:operation.responseString];
                                           [self.tableView reloadData];
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

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return detailItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row == 0) {
        SuitBasic *basic = [detailItems objectAtIndex:row];
        suitStateId = basic.suitStateId;
        return 230.0 + basic.viewAddHeight;
    }
    else if (row == 1) {
        SuitReply *reply = [detailItems objectAtIndex:row];
        return 85.0 + reply.viewAddHeight ;
    }
    else
    {
        SuitResult *result = [detailItems objectAtIndex:row];
        if (suitStateId == 2) {
            return 250.0 + result.addViewHeight - 68;
        }
        else
        {
            return 250.0 + result.addViewHeight;
        }
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
    if (row == 0) {
        SuitBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:SuitBasicCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SuitBasicCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[SuitBasicCell class]]) {
                    cell = (SuitBasicCell *)o;
                    break;
                }
            }
        }
        SuitBasic *basic = [detailItems objectAtIndex:row];
        
        suitStateId = basic.suitStateId;
        
        cell.suitTimeLb.text = basic.starttime;
        cell.suitTypeLb.text = basic.suitTypeName;
        cell.suitContentLb.text = basic.suitContent;
        
        CGRect contentFrame = cell.suitContentLb.frame;
        contentFrame.size.height = basic.contentHeight;
        cell.suitContentLb.frame = contentFrame;
        
        CGRect imageFrame = cell.suitImageFrameView.frame;
        imageFrame.origin.y += basic.viewAddHeight;
        cell.suitImageFrameView.frame = imageFrame;
        
        CGRect basicFrame = cell.basicView.frame;
        basicFrame.size.height += basic.viewAddHeight;
        cell.basicView.frame = basicFrame;
        
        if ([basic.fullImgList count] > 0) {
            //加载图片
            cell.navigationController = self.navigationController;
            [cell loadSuitImage:basic.fullImgList];
        }
        else
        {
            UILabel *noImageLb = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 25.0, 310.0, 67.0)];
            noImageLb.font = [UIFont systemFontOfSize:14];
            noImageLb.textAlignment = UITextAlignmentCenter;
            noImageLb.text = @"无照片";
            [cell.suitImageFrameView addSubview:noImageLb];
        }
        
        return cell;
    }
    else if (row == 1) {
        SuitReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:SuitReplyCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SuitReplyCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[SuitReplyCell class]]) {
                    cell = (SuitReplyCell *)o;
                    break;
                }
            }
        }
        SuitReply *reply = [detailItems objectAtIndex:row];
        cell.repalyTimeLb.text = reply.replyTime;
        cell.repalyContentLb.text = reply.replyContent;
        
        CGRect contentFrame = cell.repalyContentLb.frame;
        contentFrame.size.height = reply.contentHeight;
        cell.repalyContentLb.frame = contentFrame;
        
        CGRect bottomFrame = cell.repalyContentFrameView.frame;
        bottomFrame.size.height += reply.viewAddHeight;
        cell.repalyContentFrameView.frame = bottomFrame;
        return cell;
    }
    else
    {
        SuitResutCell *cell = [tableView dequeueReusableCellWithIdentifier:SuitResutCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SuitResutCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[SuitResutCell class]]) {
                    cell = (SuitResutCell *)o;
                    break;
                }
            }
        }
        SuitResult *result = [detailItems objectAtIndex:row];
        cell.resultContentTv.text = result.userRecontent;
        self.userRecontent = cell.resultContentTv;
        [cell.submitScoreBtn addTarget:self action:@selector(submitScoreAction:) forControlEvents:UIControlEventTouchUpInside];
        self.submitScoreBtn = cell.submitScoreBtn;
        
        //绑定ResultContentTv委托
        [cell bindResultContentTvDelegate];
        
        //如果已评价则不能再修改
        if (suitStateId == 2) {
            cell.resultContentTv.editable = NO;
            cell.resultContentPlaceholder.hidden = YES;
            cell.submitScoreBtn.hidden = YES;
        }
        else
        {
            cell.resultContentTv.editable = YES;
            cell.resultContentPlaceholder.hidden = NO;
            cell.submitScoreBtn.hidden = NO;
        }
        
        UIImage *dot, *star;
        dot = [UIImage imageNamed:@"star_gray.png"];
        star = [UIImage imageNamed:@"star_orange.png"];
        
        suitResultArray = result.suitResult;
        
        for (int i = 0; i < [result.suitResult count]; i++) {
            SuitResultItem *item = [result.suitResult objectAtIndex:i];
            UIView *itemView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 39.0 * i, 320.0, 39.0)];
            
            UILabel *itemNameLb = [[UILabel alloc]initWithFrame:CGRectMake(8.0, 9.0, 87.0, 21.0)];
            itemNameLb.font = [UIFont systemFontOfSize:14];
            itemNameLb.text = item.dimensionName;
            itemNameLb.textColor = [UIColor colorWithRed:137.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0];
            [itemView addSubview:itemNameLb];
            
            UILabel *bottomLb = [[UILabel alloc]initWithFrame:CGRectMake(0.0, 38.0, 320.0, 1.0)];
            bottomLb.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
            [itemView addSubview:bottomLb];
            
            //星级评价
            AMRatingControl *scoreControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(195, 10) emptyImage:dot solidImage:star andMaxRating:5];
            scoreControl.tag = i;
            scoreControl.update = @selector(updateScoreRating:);
            scoreControl.targer = self;
            [scoreControl setRating:item.score];
            
            [itemView addSubview:scoreControl];
            //如果已评价则不能再修改分值
            if (suitStateId == 2) {
                scoreControl.enabled = NO;
            }
            else
            {
                scoreControl.enabled = YES;
            }
            
            [cell.scoreFrameView addSubview:itemView];
        }
        
        CGRect scoreViewFrame = cell.scoreFrameView.frame;
        scoreViewFrame.size.height += result.addViewHeight;
        cell.scoreFrameView.frame = scoreViewFrame;
        
        CGRect resultContentFrame = cell.resultContentView.frame;
        resultContentFrame.origin.y += result.addViewHeight;
        //如果已评价则减去评价按钮高度
        if (suitStateId == 2) {
            resultContentFrame.size.height -= 68;
        }
        cell.resultContentView.frame = resultContentFrame;
        
        return cell;
    }
}

- (void)updateScoreRating:(id)sender
{
    AMRatingControl *scoreControl = (AMRatingControl *)sender;
    SuitResultItem *item = [suitResultArray objectAtIndex:scoreControl.tag];
    item.score = [scoreControl rating];
}

- (void)submitScoreAction:(id)sender
{
    self.submitScoreBtn.enabled = NO;
    NSMutableString *scoreMutable = [[NSMutableString alloc] init];
    for (SuitResultItem *item in suitResultArray) {
        NSString *scoreItem = [NSString stringWithFormat:@"%d,%d;", item.dimensionId, item.score];
        [scoreMutable appendString:scoreItem];
    }
    NSString *sorce = [[NSString stringWithString:scoreMutable] substringToIndex:[scoreMutable length] -1];
    NSString *userRecontent = self.userRecontent.text;
    
    //生成提交报修评价URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:sorce forKey:@"sorce"];
    [param setValue:self.suitWorkId forKey:@"suitWorkId"];
    if ([userRecontent length] > 0) {
        [param setValue:userRecontent forKey:@"userRecontent"];
    }
    NSString *modiSuitWorkOverSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_modiSuitWorkOver] params:param];
    NSString *modiSuitWorkOverUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_modiSuitWorkOver];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:modiSuitWorkOverUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:sorce forKey:@"sorce"];
    [request setPostValue:self.suitWorkId forKey:@"suitWorkId"];
    if ([userRecontent length] > 0) {
        [request setPostValue:userRecontent forKey:@"userRecontent"];
    }
    [request setPostValue:modiSuitWorkOverSign forKey:@"sign"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestModiSuitWorkOver:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交评价..." andView:self.view andHUD:request.hud];
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.submitScoreBtn.enabled = YES;
}
- (void)requestModiSuitWorkOver:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
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
        self.submitScoreBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"谢谢您的对我们的评价！" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:3];
        self.submitScoreBtn.hidden = YES;
        [self getSuitDetailData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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