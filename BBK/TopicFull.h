//
//  TopicFull.h
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicFull : NSObject

@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) NSString *regUserId;
@property (nonatomic, retain) NSString *regUserName;
@property (nonatomic, retain) NSString *nickName;
@property int replyCount;
@property int heartCount;
@property (nonatomic, retain) NSString *photoFull;
@property int isHeart;//当前用户有无点赞
@property (nonatomic, retain) NSString *starttimeStamp;
@property (nonatomic, retain) NSArray *imgUrlList;
@property (nonatomic, retain) NSMutableArray *replyList;
@property int typeId;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSString *starttime;
@property (nonatomic, retain) NSString *content;
@property int stateId;
@property (nonatomic, retain) NSString *stateName;

@property int contentHeight;
@property int imageViewHeight;
@property int replyHeight;
@property int viewAddHeight;

@end
