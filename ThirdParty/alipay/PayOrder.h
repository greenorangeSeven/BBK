//
//  Product.h
//  AlipaySdkDemo
//
//  Created by mac on 14-8-19.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayOrder : NSObject

@property (nonatomic,copy) NSString *out_no;
//商品标题
@property (nonatomic,copy) NSString *subject;

//商品描述
@property (nonatomic,copy) NSString *body;

//合作身份者id，以2088开头的16位纯数字
@property (nonatomic,copy) NSString *partnerID;

//收款支付宝账号
@property (nonatomic,copy) NSString *sellerID;

//商户私钥，自助生成
@property (nonatomic,copy) NSString *partnerPrivKey;

//商品价格
@property (nonatomic) double price;
@end
