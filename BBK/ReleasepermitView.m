//
//  ReleasepermitView.m
//  BBK
//
//  Created by Seven on 14-12-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ReleasepermitView.h"
#import "ReleasepermitCell.h"

@interface ReleasepermitView ()
{
    NSMutableArray *permits;
}

@end

@implementation ReleasepermitView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"电子放行单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"发布" style:UIBarButtonItemStyleBordered target:self action:@selector(publishAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableHeaderView = self.headerView;
    
    [self findPermits];
}

- (void)publishAction:(id)sender
{
    
}

- (void)findPermits
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //查询指定用户的物品借用记录URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        
        NSString *findBorrowRecordsUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBorrowRecordsByUserId] params:param];
        [[AFOSCClient sharedClient]getPath:findBorrowRecordsUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           [permits removeAllObjects];
                                           permits = [Tool readJsonStrToBorrowRecordsArray:operation.responseString];
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
    return permits.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReleasepermitCell *cell = [tableView dequeueReusableCellWithIdentifier:ReleasepermitCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ReleasepermitCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ReleasepermitCell class]]) {
                cell = (ReleasepermitCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    BorrowRecord *record = [permits objectAtIndex:row];
    
    return cell;
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
