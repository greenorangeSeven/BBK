//
//  UserHouse.h
//  BBK
//
//  Created by Seven on 14-11-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserHouse : NSObject

@property (nonatomic, retain) NSNumber *userStateId;
@property (nonatomic, retain) NSString *userStateName;
//userTypeId=0为业主，userTypeId=1为家属
@property (nonatomic, retain) NSNumber *userTypeId;
@property (nonatomic, retain) NSString *userTypeName;
@property (nonatomic, retain) NSString *cellId;
@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, retain) NSString *buildingName;
@property (nonatomic, retain) NSString *numberId;
@property (nonatomic, retain) NSString *numberName;
@property (nonatomic, retain) NSString *regUserId;
@property (nonatomic, retain) NSString *phone;

@property BOOL isDefault;

@end
