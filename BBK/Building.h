//
//  Building.h
//  BBK
//
//  Created by Seven on 14-11-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Building : NSObject

@property (nonatomic, retain) NSString *buildingId;
@property (nonatomic, retain) NSString *buildingName;

@property (nonatomic, retain) NSArray *subList;
@property (nonatomic, retain) NSArray *unitList;

@end
