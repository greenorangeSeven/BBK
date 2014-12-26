//
//  TransitionView.m
//  BBK
//
//  Created by Seven on 14-12-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "TransitionView.h"

@interface TransitionView ()

@end

@implementation TransitionView

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!IS_IPHONE_5) {
        self.defaultIV.image = [UIImage imageNamed:@"transition"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
