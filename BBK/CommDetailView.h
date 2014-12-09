//
//  CommDetailView.h
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommDetailView : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) NSString *titleStr;
@property (weak, nonatomic) NSString *urlStr;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
