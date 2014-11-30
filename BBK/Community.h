//
//  Community.h
//  BBK
//
//  Created by Seven on 14-11-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Community : NSObject

@property (nonatomic, retain) NSString *cellId;
@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, retain) NSString *cellAddress;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, retain) NSString *phone;

@property (nonatomic, retain) NSArray *subList;
@property (nonatomic, retain) NSArray *buildingList;

@end
