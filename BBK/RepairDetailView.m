//
//  RepairDetailView.m
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RepairDetailView.h"
#import "TransitionView.h"
#import "RepairBasicCell.h"

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
            NSString *getRepairListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRepairWorkDetaile] params:param];
            
            [[AFOSCClient sharedClient]getPath:getRepairListUrl parameters:Nil
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
//    if (row == 1) {
        return 230.0;
//    }
//    else
//    {
//        return 45.0;
//    }
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
        //            Repair *repair = [repairs objectAtIndex:row];
        //            cell.starttimeLb.text = repair.starttime;
        //            cell.repairContentLb.text = repair.repairContent;
        //            cell.stateNameLb.text = repair.stateName;
        //            if ([repair.stateSort isEqualToString:@"1"]) {
        //                cell.stateNameLb.textColor = [Tool getColorForMain];
        //            }
        //            else
        //            {
        //                cell.stateNameLb.textColor = [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
        //            }
        return cell;
    }
    else
    {
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
        //            Repair *repair = [repairs objectAtIndex:row];
        //            cell.starttimeLb.text = repair.starttime;
        //            cell.repairContentLb.text = repair.repairContent;
        //            cell.stateNameLb.text = repair.stateName;
        //            if ([repair.stateSort isEqualToString:@"1"]) {
        //                cell.stateNameLb.textColor = [Tool getColorForMain];
        //            }
        //            else
        //            {
        //                cell.stateNameLb.textColor = [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
        //            }
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
