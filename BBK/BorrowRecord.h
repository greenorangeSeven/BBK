//
//  BorrowRecord.h
//  BBK
//
//  Created by Seven on 14-12-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BorrowRecord : NSObject

@property (nonatomic, retain) NSString *goodsName;
@property (nonatomic, retain) NSString *borrowId;
@property (nonatomic, retain) NSString *goodsId;

@property int borrowNum;
@property (nonatomic, retain) NSString *userId;
@property int borrowType;

@property (nonatomic, retain) NSString *starttime;
@property (nonatomic, retain) NSString *starttimeStamp;
@property (nonatomic, retain) NSString *endtime;

@end
