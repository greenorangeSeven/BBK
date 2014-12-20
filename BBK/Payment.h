//
//  Payment.h
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject

@property (nonatomic, retain) NSString *vcusname;//用户名
@property (nonatomic, retain) NSString *unitname;//小区名
@property (nonatomic, retain) NSString *vbuildingname;//楼栋
@property (nonatomic, retain) NSString *vhnum;//房号
@property (nonatomic, retain) NSString *dbildateStr;//时间
@property (nonatomic, retain) NSNumber *srnrevmny;//费用

@end
