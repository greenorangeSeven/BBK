//
//  ServiceOrderView.m
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ServiceOrderView.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"

@interface ServiceOrderView ()
{
    UIWebView *phoneWebView;
}

@end

@implementation ServiceOrderView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"服务预约";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UserModel *userModel = [UserModel Instance];
    [self.userFaceIv setImageWithURL:[NSURL URLWithString:[userModel getUserValueForKey:@"photoFull"]] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.userInfoLb.text = [NSString stringWithFormat:@"%@(%@)", [userModel getUserValueForKey:@"regUserName"], [userModel getUserValueForKey:@"mobileNo"]];
    self.userAddressLb.text = [NSString stringWithFormat:@"%@%@%@--%@", [userModel getUserValueForKey:@"cellName"], [userModel getUserValueForKey:@"buildingName"], [userModel getUserValueForKey:@"numberName"], [userModel getUserValueForKey:@"userTypeName"]];
    
    self.orderContentTv.delegate = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    [self.orderDateLb setText:timestamp];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0) {
        [self.orderContentPlaceholder setHidden:NO];
    }else{
        [self.orderContentPlaceholder setHidden:YES];
    }
}

- (IBAction)selectOrderTimeAction:(id)sender {
    if (IS_IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        self.dateTimePicker = [[UIDatePicker alloc] init];
        self.dateTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [self.dateTimePicker addTarget:self
                                action:@selector(dateChanged:)
                      forControlEvents:UIControlEventValueChanged];
        [alert.view addSubview:self.dateTimePicker];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"确  定", nil];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        self.dateTimePicker = [[UIDatePicker alloc] init];
        self.dateTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [self.dateTimePicker addTarget:self
                                action:@selector(dateChanged:)
                      forControlEvents:UIControlEventValueChanged];
        [actionSheet addSubview:self.dateTimePicker];
    }
}

-(void) dateChanged:(id)sender
{
    NSDate *select = [self.dateTimePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    self.orderDateLb.text = dateAndTime;
}

- (IBAction)telServiceAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [[UserModel Instance] getUserValueForKey:@"cellPhone"]]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (IBAction)submitOrderAction:(id)sender
{
    NSString *contentStr = self.orderContentTv.text;
    if (contentStr == nil || [contentStr length] == 0) {
        [Tool showCustomHUD:@"请填写报修描述" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    self.submitOrderBtn.enabled = NO;
    
    UserModel *userModel = [UserModel Instance];
    
    //生成新增预约服务Sign
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:contentStr forKey:@"content"];
    [param setValue:self.orderDateLb.text forKey:@"starttime"];
    [param setValue:[userModel getUserValueForKey:@"regUserId"] forKey:@"regUserId"];
    [param setValue:[userModel getUserValueForKey:@"cellId"] forKey:@"cellId"];
    NSString *addCelebrationSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCelebrationInfo] params:param];
    
    NSString *addCelebrationUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_addCelebrationInfo];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:addCelebrationUrl]];
    [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
    [request setTimeOutSeconds:30];
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:addCelebrationSign forKey:@"sign"];
    [request setPostValue:contentStr forKey:@"content"];
    [request setPostValue:self.orderDateLb.text forKey:@"starttime"];
    [request setPostValue:[userModel getUserValueForKey:@"regUserId"] forKey:@"regUserId"];
    [request setPostValue:[userModel getUserValueForKey:@"cellId"] forKey:@"cellId"];
    
    request.delegate = self;
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交预约" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    if(self.submitOrderBtn.enabled == NO)
    {
        self.submitOrderBtn.enabled = YES;
    }
}

- (void)requestSubmit:(ASIHTTPRequest *)request
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
        self.submitOrderBtn.enabled = YES;
        return;
    }
    else
    {
        [Tool showCustomHUD:@"预约成功" andView:self.parentView  andImage:@"37x-Failure.png" andAfterDelay:1];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)pushServiceCostView:(id)sender
{
    NSString *pushDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_celebrationItemsList ,Appkey];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"收费标准";
    detailView.urlStr = pushDetailHtm;
    [self.navigationController pushViewController:detailView animated:YES];
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
