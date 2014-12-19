//
//  CircleOfFriendsView.h
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleOfFriendsView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    NSMutableArray *topics;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    int selectRow;
}

@property (weak, nonatomic) IBOutlet UILabel *recordNumLb;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)publicTopicAction:(id)sender;
- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
