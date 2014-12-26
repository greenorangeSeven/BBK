//
//  PropertyPageView.h
//  BBK
//
//  Created by Seven on 14-12-1.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface PropertyPageView : UIViewController<SGFocusImageFrameDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>
{
    Notice *notice;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *noticeTitleLb;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;
- (IBAction)noticeDetailAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *gatePassBtn;
@property (weak, nonatomic) IBOutlet UILabel *gatePassLb;

//物业通知
- (IBAction)noticesAction:(id)sender;
//物业呼叫
- (IBAction)callServiceAction:(id)sender;
//物品借用
- (IBAction)goodBorrowAction:(id)sender;
//快递收发
- (IBAction)expressAction:(id)sender;
//物业报修
- (IBAction)addRepairAction:(id)sender;
//投诉建议
- (IBAction)addSuitWorkAction:(id)sender;
//访客通行证
- (IBAction)pushGatePassAction:(id)sender;
//账单推送
- (IBAction)pushPaymentListView:(id)sender;
//交易买卖
- (IBAction)pushTradeViewAction:(id)sender;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
