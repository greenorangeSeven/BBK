//
//  SuitDetailView.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuitDetailView : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (copy, nonatomic) NSString *present;
@property (copy, nonatomic) NSString *suitWorkId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
