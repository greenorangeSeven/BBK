//
//  RepairBasic.h
//  BBK
//
//  Created by Seven on 14-12-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//  报修基本信息
//

#import <Foundation/Foundation.h>

@interface RepairBasic : NSObject

@property (nonatomic, retain) NSString *stateSort;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSArray *imgList;
@property (nonatomic, retain) NSMutableArray *fullImgList;
@property (nonatomic, retain) NSString *repairContent;

@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *starttime;

@property int contentHeight;
@property int viewAddHeight;

//维修
@property (nonatomic, retain) NSString *repairmanId;
@property (nonatomic, retain) NSString *repairmanName;
@property (nonatomic, retain) NSString *mobileNo;

@property (nonatomic, retain) NSArray *repairRunList;
//完工
@property (nonatomic, retain) NSString *runContent;
@property double cost;

//评价
@property (nonatomic, retain) NSArray *repairResult;
@property (nonatomic, retain) NSString *userRecontent;

@end
