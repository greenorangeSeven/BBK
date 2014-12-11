//
//  RepairDetailView.m
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RepairDetailView.h"

@interface RepairDetailView ()

@end

@implementation RepairDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getRepairDetailUrl];
}

- (void)getRepairDetailUrl
{
    //生成获取报修列表URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.repair.repairWorkId forKey:@"repairWorkId"];
    NSString *getRepairListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRepairWorkDetaile] params:param];
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
