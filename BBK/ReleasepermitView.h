//
//  ReleasepermitView.h
//  BBK
//
//  Created by Seven on 14-12-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReleasepermitView : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *mobileTf;
@property (weak, nonatomic) IBOutlet UITextField *carNumTf;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
