//
//  BorrowGoodFromView.m
//  BBK
//
//  Created by Seven on 14-12-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "BorrowGoodFromView.h"
#import "UIImageView+WebCache.h"

@interface BorrowGoodFromView ()
{
    NSMutableArray *typeArray;
    NSMutableArray *numberArray;
    
    NSString *typeId;
}

@end

@implementation BorrowGoodFromView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"物品借用";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"借用" style:UIBarButtonItemStyleBordered target:self action:@selector(borrowGoodAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.goodImageIv setImageWithURL:[NSURL URLWithString:self.good.imgUrlFull] placeholderImage:[UIImage imageNamed:@"loadpic"]];
    self.goodNameLb.text = self.good.goodsName;
    
    int residueGood = [self.good.goodsNum intValue] - [self.good.borrowCount intValue];
    self.goodNumberLb.text = [NSString stringWithFormat:@"剩余%d件", residueGood];
    [Tool roundTextView:self.goodBoxView andBorderWidth:0.5 andCornerRadius:5.0];
    
    typeId = @"1";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    [self.borrowTimeLb setText:timestamp];
    
    NSDictionary *type1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"自取", @"typeName", @"0", @"typeId", nil];
    NSDictionary *type2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"送物上门", @"typeName", @"1", @"typeId", nil];
    typeArray = [[NSMutableArray alloc] initWithObjects:type1, type2, nil];
    
    numberArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= residueGood; i++) {
        [numberArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
}

- (void)borrowGoodAction:(id *)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    
    //生成物品借用URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.good.goodsId forKey:@"goodsId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    [param setValue:self.borrowNumLb.text forKey:@"borrowNum"];
    [param setValue:self.borrowTimeLb.text forKey:@"starttime"];
    [param setValue:typeId forKey:@"borrowType"];
    NSString *borrowGoodsSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_borrowGoods] params:param];
    NSString *borrowGoodsUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_borrowGoods];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:borrowGoodsUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:borrowGoodsSign forKey:@"sign"];
    [request setPostValue:self.good.goodsId forKey:@"goodsId"];
    [request setPostValue:userInfo.regUserId forKey:@"regUserId"];
    [request setPostValue:self.borrowNumLb.text forKey:@"borrowNum"];
    [request setPostValue:self.borrowTimeLb.text forKey:@"starttime"];
    [request setPostValue:typeId forKey:@"borrowType"];
    
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestBorrowGoods:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"提交借用..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
        
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)requestBorrowGoods:(ASIHTTPRequest *)request
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
        [Tool showCustomHUD:@"物品借用成功" andView:self.parentView andImage:@"37x-Failure.png" andAfterDelay:2];

        [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)selectTypeAction:(id)sender {
    NSDictionary *typeDic = [typeArray objectAtIndex:0];
    self.borrowTypeLb.text = [typeDic objectForKey:@"typeName"];
    typeId = [typeDic objectForKey:@"typeId"];
    
    if (IS_IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIPickerView *typePicker = [[UIPickerView alloc] init];
        typePicker.delegate = self;
        typePicker.showsSelectionIndicator = YES;
        typePicker.tag = 1;
        [alert.view addSubview:typePicker];
        
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
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
        UIPickerView *typePicker = [[UIPickerView alloc] init];
        typePicker.delegate = self;
        typePicker.showsSelectionIndicator = YES;
        typePicker.tag = 1;
        [actionSheet addSubview:typePicker];
    }
}

- (IBAction)selectTimeAction:(id)sender {
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
    self.borrowTimeLb.text = dateAndTime;
}

- (IBAction)selectNumAction:(id)sender {
    NSString *numStr = [numberArray objectAtIndex:0];
    self.borrowNumLb.text = numStr;
    if (IS_IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIPickerView *numPicker = [[UIPickerView alloc] init];
        numPicker.delegate = self;
        numPicker.showsSelectionIndicator = YES;
        numPicker.tag = 2;
        [alert.view addSubview:numPicker];
        
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
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
        UIPickerView *numPicker = [[UIPickerView alloc] init];
        numPicker.delegate = self;
        numPicker.showsSelectionIndicator = YES;
        numPicker.tag = 2;
        [actionSheet addSubview:numPicker];
    }
}

//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 1) {
        return 1;
    }
    else if (pickerView.tag == 2) {
        return 1;
    }
    else
    {
        return 0;
    }
}

//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return [typeArray count];
    }
    else if (pickerView.tag == 2) {
        return [numberArray count];
    }
    else
    {
        return 0;
    }
    
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        NSDictionary *typeDic = [typeArray objectAtIndex:row];
        return [typeDic objectForKey:@"typeName"];
    }
    else if (pickerView.tag == 2)
    {
        NSString *numStr = [numberArray objectAtIndex:row];
        return numStr;
    }
    else
    {
        return nil;
    }
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    if (pickerView.tag == 1) {
        NSDictionary *typeDic = [typeArray objectAtIndex:row];
        self.borrowTypeLb.text = [typeDic objectForKey:@"typeName"];
        typeId = [typeDic objectForKey:@"typeId"];
    }
    else if (pickerView.tag == 2)
    {
        NSString *numStr = [numberArray objectAtIndex:row];
        self.borrowNumLb.text = numStr;
    }
}

@end
