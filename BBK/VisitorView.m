//
//  VisitorView.m
//  BBK
//
//  Created by Seven on 15-1-19.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "VisitorView.h"
#import "LifeReferView.h"
#import "ConvenienceTypeView.h"
#import "ShopTypeView.h"
#import "MonthlyView.h"
#import "CommDetailView.h"

@interface VisitorView ()

@end

@implementation VisitorView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"游客";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
}

- (void)didReceiveMemoryWarning {
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
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//生活查询
- (IBAction)LifeReferAction:(id)sender {
    LifeReferView *lifeReferView = [[LifeReferView alloc] init];
    lifeReferView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lifeReferView animated:YES];
}

//便民服务
- (IBAction)convenienceTypeAction:(id)sender {
    ConvenienceTypeView *convenienceView = [[ConvenienceTypeView alloc] init];
    convenienceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:convenienceView animated:YES];
}

//周边商家
- (IBAction)ShopTypeAction:(id)sender {
    ShopTypeView *shopTypeView = [[ShopTypeView alloc] init];
    shopTypeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:shopTypeView animated:YES];
}

//悦月刊
- (IBAction)pushMonthlyViewAction:(id)sender {
    MonthlyView *monthlyView = [[MonthlyView alloc] init];
    monthlyView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:monthlyView animated:YES];
}

//步步高商城
- (IBAction)pushBuBuGaoWeb:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://yunhou.com/"]];
}

//关于我们
- (IBAction)aboutUs:(id)sender
{
    NSString *bubugaoHtm = [NSString stringWithFormat:@"%@%@", api_base_url, htm_about];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"关于步步高智慧社区";
    detailView.urlStr = bubugaoHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

@end
