//
//  PaymentItem.h
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentItem : NSObject

@property (nonatomic, retain) NSString *vbillno;
@property (nonatomic, retain) NSString *vname;
@property double srnrevmny;
@property (nonatomic, retain) NSString *dbildate;
@property (nonatomic, retain) NSNumber *dbildateStamp;

@end
