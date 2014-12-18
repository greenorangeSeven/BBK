//
//  TopicReply.h
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicReply : NSObject

@property (nonatomic, retain) NSString *replyId;
@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) NSString *regUserName;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *regUserId;
@property (nonatomic, retain) NSString *replyTime;
@property (nonatomic, retain) NSString *replyContent;
@property (nonatomic, retain) NSMutableAttributedString *replyContentAttr;
@property int stateId;
@property (nonatomic, retain) NSString *stateName;

@property int contentHeight;

@end
