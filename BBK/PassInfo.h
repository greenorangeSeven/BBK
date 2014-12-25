//
//  PassInfo.h
//  BBK
//
//  Created by Seven on 14-12-16.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PassInfo : NSObject

@property (nonatomic, retain) NSString *passId;
@property (nonatomic, retain) NSString *passType;
@property int hours;
@property (nonatomic, retain) NSString *passMobile;
@property (nonatomic, retain) NSString *code;

@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *starttime;

@property (nonatomic, retain) NSString *cellName;
@property (nonatomic, retain) NSString *buildingName;
@property (nonatomic, retain) NSString *numberName;
@property (nonatomic, retain) NSString *carLicense;

@end
