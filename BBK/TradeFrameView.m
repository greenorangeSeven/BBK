//
//  TradeFrameView.m
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "TradeFrameView.h"

@interface TradeFrameView ()

@end

@implementation TradeFrameView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"交易买卖";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle: @"发布" style:UIBarButtonItemStyleBordered target:self action:@selector(publishTradeAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //下属控件初始化
    self.esjyView = [[TradeListView alloc] init];
    self.esjyView.typeId = @"0";
    self.esjyView.typeName = @"二手交易";
    self.esjyView.frameView = self.mainView;
    [self addChildViewController:self.esjyView];
    [self.mainView addSubview:self.esjyView.view];
    
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)getTradeType
{
    NSString *getMyExpressListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@/zhxq_api/business/findAllBusinessType.htm", api_base_url] params:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)item1Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundColor:[Tool getColorForMain]];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundColor:[UIColor whiteColor]];
    [self.item3Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item3Btn setBackgroundColor:[UIColor whiteColor]];
    self.esjyView.view.hidden = NO;
    self.fwcsView.view.hidden = YES;
    self.fwczView.view.hidden = YES;
}

- (IBAction)item2Action:(id)sender {
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundColor:[UIColor whiteColor]];
    [self.item2Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundColor:[Tool getColorForMain]];
    [self.item3Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item3Btn setBackgroundColor:[UIColor whiteColor]];
    if (self.fwcsView == nil) {
        self.fwcsView = [[TradeListView alloc] init];
        self.fwcsView.typeId = @"1";
        self.fwcsView.typeName = @"房屋出售";
        self.fwcsView.frameView = self.mainView;
        [self addChildViewController:self.fwcsView];
        [self.mainView addSubview:self.fwcsView.view];
    }
    self.esjyView.view.hidden = YES;
    self.fwcsView.view.hidden = NO;
    self.fwczView.view.hidden = YES;
}

- (IBAction)item3Action:(id)sender {
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundColor:[UIColor whiteColor]];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundColor:[UIColor whiteColor]];
    [self.item3Btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.item3Btn setBackgroundColor:[Tool getColorForMain]];
    if (self.fwczView == nil) {
        self.fwczView = [[TradeListView alloc] init];
        self.fwczView.typeId = @"2";
        self.fwczView.typeName = @"房屋出租";
        self.fwczView.frameView = self.mainView;
        [self addChildViewController:self.fwczView];
        [self.mainView addSubview:self.fwczView.view];
    }
    self.esjyView.view.hidden = YES;
    self.fwcsView.view.hidden = YES;
    self.fwczView.view.hidden = NO;
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

@end
