//
//  ChangeHouseView.m
//  BBK
//
//  Created by Seven on 14-12-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ChangeHouseView.h"
#import "UserHouse.h"
#import "ChangeHouseCell.h"
#import "XGPush.h"

@interface ChangeHouseView ()
{
    NSArray *userHouses;
    UserHouse *defaultUserHouse;
}

@end

@implementation ChangeHouseView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"切换房间";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UserInfo *userInfo = [[UserModel Instance] getUserInfo];
    userHouses = userInfo.rhUserHouseList;
    defaultUserHouse = userInfo.defaultUserHouse;
    
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userHouses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChangeHouseCell *cell = [tableView dequeueReusableCellWithIdentifier:ChangeHouseCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ChangeHouseCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ChangeHouseCell class]]) {
                cell = (ChangeHouseCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    UserHouse *house = [userHouses objectAtIndex:row];
    cell.userInfoLb.text = [NSString stringWithFormat:@"%@%@%@", house.cellName, house.buildingName, house.numberName];
    cell.userTypeNameLb.text = house.userTypeName;
    cell.userStateNameLb.text = house.userStateName;
    
    if ([defaultUserHouse.numberId isEqualToString:house.numberId] == YES) {
        cell.changeBtn.enabled = NO;
        [cell.changeBtn setTitle:@"当前" forState:UIControlStateDisabled];
        [cell.changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.changeBtn setBackgroundImage:[UIImage imageNamed:@"button_orange"] forState:UIControlStateDisabled];
    }
    else
    {
        cell.changeBtn.enabled = YES;
        [cell.changeBtn setTitle:@"设为默认" forState:UIControlStateNormal];
        [cell.changeBtn setTitleColor:[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [cell.changeBtn setBackgroundImage:[UIImage imageNamed:@"button_gary"] forState:UIControlStateNormal];
        cell.changeBtn.tag = row;
    }
    
    [cell.changeBtn addTarget:self action:@selector(changeHouseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)changeHouseAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        
        //房间切换先移除原默认小区ID推送TAG
        [XGPush delTag:defaultUserHouse.cellId];
        
        UserHouse *house = [userHouses objectAtIndex:tap.tag];
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        userInfo.defaultUserHouse = house;
        [[UserModel Instance] saveUserInfo:userInfo];
        defaultUserHouse = house;
        
        //切换后再设置用户小区ID推送TAG
        [XGPush setTag:defaultUserHouse.cellId];
        
        [self.tableView reloadData];
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
