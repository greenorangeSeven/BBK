//
//  SuitReply.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuitReply : NSObject

@property (nonatomic, retain) NSString *replyContent;

@property (nonatomic, retain) NSNumber *replyTimeStamp;
@property (nonatomic, retain) NSString *replyTime;

@property int contentHeight;
@property int viewAddHeight;

@end
