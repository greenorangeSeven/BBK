//
//  Activity.h
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject

@property int userCount;
@property (nonatomic, retain) NSString *activityId;
@property (nonatomic, retain) NSString *activityName;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *qq;
@property (nonatomic, retain) NSString *starttime;
@property (nonatomic, retain) NSString *endtime;
@property (nonatomic, retain) NSString *qualifications;
@property int heartCount;
@property (nonatomic, retain) NSString *imgUrlFull;

@end
