//
//  Suit.h
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Suit : NSObject

@property (nonatomic, retain) NSString *suitWorkId;
@property (nonatomic, retain) NSString *suitContent;
@property (nonatomic, retain) NSString *starttime;
@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *regUserName;
@property (nonatomic, retain) NSString *suitTypeName;
@property int suitTypeId;
@property (nonatomic, retain) NSString *suitStateName;
@property int suitStateId;

@end
