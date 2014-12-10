//
//  ShopInfo.h
//  BBK
//
//  Created by Seven on 14-12-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopInfo : NSObject

@property (nonatomic, retain) NSString *shopId;
@property (nonatomic, retain) NSString *shopName;
@property (nonatomic, retain) NSString *shopAddress;
@property (nonatomic, retain) NSString *phone;
@property double longitude;
@property double latitude;
@property double distance;
@property (nonatomic, retain) NSString *remark;
@property (nonatomic, retain) NSString *imgUrlFull;

@property (nonatomic, retain) UIImage *imgData;

@end
