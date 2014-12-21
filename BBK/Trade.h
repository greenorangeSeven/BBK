//
//  Trade.h
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trade : NSObject

@property (nonatomic, retain) NSString *businessId;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, retain) NSString *phone;
@property double price;
@property int priceUnit;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *priceUnitName;
@property (nonatomic, retain) NSString *imgUrlFull;
@property (nonatomic, retain) NSString *starttime;
@property int infoFrom;
@property (nonatomic, retain) NSString *userId;
@property int typeId;
@property int stateId;

@end
