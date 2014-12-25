//
//  RepairDetailView.h
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairDetailView : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (copy, nonatomic) NSString *present;
@property (copy, nonatomic) NSString *repairWorkId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
