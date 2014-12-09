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

@interface PropertyPageView : UIViewController<SGFocusImageFrameDelegate>
{
    NSMutableArray *notices;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *noticeTitleLb;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;

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

@end
