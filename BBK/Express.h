//
//  Express.h
//  BBK
//
//  Created by Seven on 14-12-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Express : NSObject

@property (nonatomic, retain) NSString *expressId;
@property (nonatomic, retain) NSNumber *starttimeStamp;
@property (nonatomic, retain) NSString *expressCompanyName;
@property (nonatomic, retain) NSString *expressOrder;
@property (nonatomic, retain) NSString *timeDiff;

@end
