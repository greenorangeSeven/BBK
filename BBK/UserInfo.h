//
//  UserInfo.h
//  BBK
//
//  Created by Seven on 14-11-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCoding>

@property (nonatomic, retain) NSString *regUserId;
@property (nonatomic, retain) NSString *regUserName;
@property (nonatomic, retain) NSString *idCardLast4;
@property (nonatomic, retain) NSString *mobileNo;
@property (nonatomic, retain) NSString *nickName;

@property (nonatomic, retain) NSArray *rhUserHouseList;

@end