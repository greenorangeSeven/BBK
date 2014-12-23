//
//  PaymentMonthDetailView.m
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PaymentMonthDetailView.h"
#import "PaymentItemCell.h"

@interface PaymentMonthDetailView ()
{
    UserInfo *userInfo;
}

@end

@implementation PaymentMonthDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物业账单";
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
    userInfo = [[UserModel Instance] getUserInfo];
    [self getPaymentByMonth];
}

- (void)getPaymentByMonth
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //月账单列表
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.buildingName forKey:@"buildName"];
        [param setValue:userInfo.defaultUserHouse.numberName forKey:@"numberName"];
        [param setValue:userInfo.regUserName forKey:@"regUserName"];
        [param setValue:self.month forKey:@"month"];
        
        NSString *paymentByMonthSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPaymentListByMonth] params:param];
        
        [param setValue:Appkey forKey:@"accessId"];
        [param setValue:paymentByMonthSign forKey:@"sign"];
        
        NSString *paymentByMonthUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_findPaymentListByMonth];
        
        [[AFOSCClient sharedClient] postPath:paymentByMonthUrl parameters:param
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         @try {
                                             items = [Tool readJsonStrToPaymentItemArray:operation.responseString];
                                             [self.tableView reloadData];
                                         }
                                         @catch (NSException *exception) {
                                             [NdUncaughtExceptionHandler TakeException:exception];
                                         }
                                         @finally {
                                             
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"列表获取出错");
                                         
                                         
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
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    PaymentItemCell *cell = [tableView dequeueReusableCellWithIdentifier:PaymentItemCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PaymentItemCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[PaymentItemCell class]]) {
                cell = (PaymentItemCell *)o;
                break;
            }
        }
    }
    PaymentItem *pay = [items objectAtIndex:row];
    cell.dateLb.text = pay.dbildate;
    cell.nameLb.text = pay.vname;
    cell.moneyLb.text = [NSString stringWithFormat:@"%.2f元", pay.srnrevmny];
    return cell;
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
