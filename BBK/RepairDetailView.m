//
//  RepairDetailView.m
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RepairDetailView.h"
#import "TransitionView.h"
#import "RepairBasic.h"
#import "RepairDispatch.h"
#import "RepairFinish.h"
#import "RepairBasicCell.h"
#import "RepairDispatchCell.h"
#import "RepairFinishCell.h"
#import "RepairResultCell.h"
#import "AMRatingControl.h"

@interface RepairDetailView ()
{
    MBProgressHUD *hud;
    NSMutableArray *detailItems;
}

@end

@implementation RepairDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"报修单";
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
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getRepairDetailData];
}

- (void)getRepairDetailData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取报修详情URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:self.repair.repairWorkId forKey:@"repairWorkId"];
        NSString *getRepairDetailUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRepairWorkDetaile] params:param];
        
        [[AFOSCClient sharedClient]getPath:getRepairDetailUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           detailItems = [Tool readJsonStrToRepairItemArray:operation.responseString];
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
        RepairBasic *basic = [detailItems objectAtIndex:row];
        return 230.0 + basic.viewAddHeight ;
    }
    else if (row == 1) {
        return 72.0 ;
    }
    else if (row == 2) {
        RepairFinish *finish = [detailItems objectAtIndex:row];
        return 176.0 + finish.viewAddHeight ;
    }
    else
    {
        RepairResult *result = [detailItems objectAtIndex:row];
        return 182.0 + result.addViewHeight;
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
        RepairBasicCell *cell = [tableView dequeueReusableCellWithIdentifier:RepairBasicCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairBasicCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[RepairBasicCell class]]) {
                    cell = (RepairBasicCell *)o;
                    break;
                }
            }
        }
        RepairBasic *basic = [detailItems objectAtIndex:row];
        cell.repairTimeLb.text = basic.starttime;
        cell.repairTypeLb.text = basic.typeName;
        cell.repairContentLb.text = basic.repairContent;
        
        CGRect contentFrame = cell.repairContentLb.frame;
        contentFrame.size.height = basic.contentHeight;
        cell.repairContentLb.frame = contentFrame;
        
        CGRect imageFrame = cell.repairImageFrameView.frame;
        imageFrame.origin.y += basic.viewAddHeight;
        cell.repairImageFrameView.frame = imageFrame;
        
        CGRect basicFrame = cell.basicView.frame;
        basicFrame.size.height += basic.viewAddHeight;
        cell.basicView.frame = basicFrame;
        
        if ([basic.fullImgList count] > 0) {
            [cell loadRepairImage:basic.fullImgList];
        }
        else
        {
            UILabel *noImageLb = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 25.0, 310.0, 67.0)];
            noImageLb.font = [UIFont systemFontOfSize:14];
            noImageLb.textAlignment = UITextAlignmentCenter;
            noImageLb.text = @"无照片";
            [cell.repairImageFrameView addSubview:noImageLb];
        }
        
        return cell;
    }
    else if (row == 1) {
        RepairDispatchCell *cell = [tableView dequeueReusableCellWithIdentifier:RepairDispatchCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairDispatchCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[RepairDispatchCell class]]) {
                    cell = (RepairDispatchCell *)o;
                    break;
                }
            }
        }
        RepairDispatch *dispatch = [detailItems objectAtIndex:row];
        cell.dispatchTimeLb.text = dispatch.starttime;
        cell.dispatchManLb.text = [NSString stringWithFormat:@"%@(%@)", dispatch.repairmanName, dispatch.mobileNo];
        return cell;
    }
    else if (row == 2) {
        RepairFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:RepairFinishCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairFinishCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[RepairFinishCell class]]) {
                    cell = (RepairFinishCell *)o;
                    break;
                }
            }
        }
        RepairFinish *finish = [detailItems objectAtIndex:row];
        cell.finishTimeLb.text = finish.starttime;
        cell.finishContentLb.text = finish.runContent;
        cell.finishCostLb.text = [NSString stringWithFormat:@"%.2f元", finish.cost];
        
        CGRect contentFrame = cell.finishContentLb.frame;
        contentFrame.size.height = finish.contentHeight;
        cell.finishContentLb.frame = contentFrame;
        
        CGRect finishFrame = cell.finishView.frame;
        finishFrame.size.height += finish.viewAddHeight;
        cell.finishView.frame = finishFrame;
        
        CGRect bottomFrame = cell.bottomView.frame;
        bottomFrame.origin.y += finish.viewAddHeight;
        cell.bottomView.frame = bottomFrame;
        return cell;
    }
    else
    {
        RepairResultCell *cell = [tableView dequeueReusableCellWithIdentifier:RepairResultCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RepairResultCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[RepairResultCell class]]) {
                    cell = (RepairResultCell *)o;
                    break;
                }
            }
        }
        RepairResult *result = [detailItems objectAtIndex:row];
        cell.resultContentTv.text = result.userRecontent;
        //如果已评价则不能再修改
        if ([result.userRecontent length] > 0) {
            cell.resultContentTv.editable = NO;
        }
        
        UIImage *dot, *star;
        dot = [UIImage imageNamed:@"star_gray.png"];
        star = [UIImage imageNamed:@"star_orange.png"];
        
        for (int i = 0; i < [result.repairResult count]; i++) {
            RepairResuleItem *item = [result.repairResult objectAtIndex:i];
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
            AMRatingControl *totalControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(207, 10) emptyImage:dot solidImage:star andMaxRating:5];
            totalControl.tag = item.dimensionId;
            [totalControl setRating:item.score];
            [totalControl addTarget:self action:@selector(updateEndRating:) forControlEvents:UIControlEventEditingDidEnd];
            [itemView addSubview:totalControl];
            //如果已评价则不能再修改分值
            if ([result.userRecontent length] > 0) {
                totalControl.enabled = NO;
            }
            
            [cell.scoreFrameView addSubview:itemView];
        }
        
        CGRect scoreItemViewFrame = cell.scoreItemView.frame;
        scoreItemViewFrame.size.height = result.scoreViewHeight;
        cell.scoreItemView.frame = scoreItemViewFrame;
        
        CGRect scoreViewFrame = cell.scoreFrameView.frame;
        scoreViewFrame.size.height += result.addViewHeight;
        cell.scoreFrameView.frame = scoreViewFrame;
        
        CGRect resultContentFrame = cell.resultContentView.frame;
        resultContentFrame.origin.y += result.addViewHeight;
        cell.resultContentView.frame = resultContentFrame;

        return cell;

    }
    
    
    
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
