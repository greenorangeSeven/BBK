//
//  ExpressView.h
//  BBK
//
//  Created by Seven on 14-12-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ExpressView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *expresses;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (copy, nonatomic) NSString *present;

@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLb;
@property (weak, nonatomic) IBOutlet UILabel *expressNumLb;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)expressHistoryAction:(id)sender;
- (IBAction)kd100Action:(id)sender;

- (void)refreshExpressData:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
