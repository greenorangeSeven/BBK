//
//  BorrowGood.h
//  BBK
//
//  Created by Seven on 14-12-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BorrowGood : NSObject

@property (nonatomic, retain) NSString *goodsId;
@property (nonatomic, retain) NSString *goodsName;
@property (nonatomic, retain) NSNumber *goodsNum;
@property (nonatomic, retain) NSString *borrowCount;
@property (nonatomic, retain) NSString *imgUrl;
@property (nonatomic, retain) NSString *imgUrlFull;

@property (nonatomic, retain) UIImage *imgData;

@end
