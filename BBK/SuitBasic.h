//
//  SuitBasic.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SuitReply.h"

@interface SuitBasic : NSObject

@property int suitStateId;
@property (nonatomic, retain) NSString *suitTypeName;
@property (nonatomic, retain) NSArray *imgList;
@property (nonatomic, retain) NSMutableArray *fullImgList;
@property (nonatomic, retain) NSString *suitContent;

@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *starttime;

@property int contentHeight;
@property int viewAddHeight;

//反馈结果
@property (nonatomic, retain) SuitReply *suitReply;

//评价
@property (nonatomic, retain) NSArray *suitResult;
@property (nonatomic, retain) NSString *userRecontent;

@end
