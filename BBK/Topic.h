//
//  Topic.h
//  BBK
//
//  Created by Seven on 14-12-7.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject

@property (nonatomic, retain) NSString *topicId;
@property (nonatomic, retain) NSString *regUserId;
@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSString *regUserName;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSArray *imgUrlList;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *photoFull;

@property (nonatomic, retain) UIImage *imgData;
@property int contentHeight;
@property (nonatomic, retain) NSString *starttime;
@property int imageViewHeight;
@property int viewAddHeight;

@end
