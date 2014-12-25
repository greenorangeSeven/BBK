//
//  ReleasepermitView.m
//  BBK
//
//  Created by Seven on 14-12-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ReleasepermitView.h"
#import "ReleasepermitCell.h"
#import "NSString+STRegex.h"

@interface ReleasepermitView ()
{
    NSMutableArray *permits;
    UserInfo *userInfo;
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
    
    userInfo = [[UserModel Instance] getUserInfo];
    
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
    [self.mobileTf resignFirstResponder];
    NSString *mobileNo = self.mobileTf.text;
    NSString *carNumStr = self.carNumTf.text;
    NSString *contentStr = self.contentTv.text;

    if (![mobileNo isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //生成访客通行证URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileNo forKey:@"mobileNo"];
    [param setValue:@"24" forKey:@"hours"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    [param setValue:@"1" forKey:@"passType"];
    if ([carNumStr length] > 0) {
        [param setValue:carNumStr forKey:@"carLicense"];
    }
    if ([contentStr length] > 0) {
        [param setValue:contentStr forKey:@"remark"];
    }
    
    NSString *createPassCodeSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_createPassCode] params:param];
    NSString *createPassCodeUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createPassCode];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createPassCodeUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:createPassCodeSign forKey:@"sign"];
    [request setPostValue:mobileNo forKey:@"mobileNo"];
    [request setPostValue:@"24" forKey:@"hours"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
    [request setPostValue:@"1" forKey:@"passType"];
    if ([carNumStr length] > 0) {
        [request setPostValue:carNumStr forKey:@"carLicense"];
    }
    if ([contentStr length] > 0) {
        [request setPostValue:contentStr forKey:@"remark"];
    }
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreatePassCode:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"发布放行单..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)requestCreatePassCode:(ASIHTTPRequest *)request
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"发布成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
        
    }
}

- (void)findPermits
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取业主放行单列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        [param setValue:@"1" forKey:@"passType"];
        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"10" forKey:@"countPerPages"];
        NSString *findPassInfoListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPassInfoByPage] params:param];
        [[AFOSCClient sharedClient]getPath:findPassInfoListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           [permits removeAllObjects];
                                           permits = [Tool readJsonStrToPassInfoArray:operation.responseString];
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
    PassInfo *info = [permits objectAtIndex:row];
    
    cell.mobileLb.text = info.passMobile;
    cell.timeLb.text = info.starttime;
    cell.carNumLb.text = [NSString stringWithFormat:@"车牌号:%@", info.carLicense];
    cell.codeLb.text = [NSString stringWithFormat:@"验证码:%@", info.code];
    
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
