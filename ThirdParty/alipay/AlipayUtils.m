//
//  AlipayUtils.m
//  AlipaySdkDemo
//
//  Created by mac on 14-8-19.
//  Copyright (c) 2014年 Alipay. All rights reserved.
//

#import "AlipayUtils.h"
#import "AlixPayOrder.h"
#import "AlixLibService.h"
#import "AlixPayResult.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import "PayOrder.h"

@implementation AlipayUtils

+ (void)doPay:(PayOrder *)payOrder NotifyURL :(NSString *) notifyURL AndScheme:(NSString *)scheme seletor:(SEL)seletor target:(id)target
{
    NSString* orderInfo = [self getOrderInfo:payOrder NotifyURL:notifyURL];
    NSString* signedStr = [self doRsa:orderInfo andKey:payOrder.partnerPrivKey];
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
	
    [AlixLibService payOrder:orderString AndScheme:scheme seletor:seletor target:target];
}

//将订单对象封装成请求参数
+(NSString*)getOrderInfo:(PayOrder *)payOrder NotifyURL :(NSString *) notifyURL
{
    
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    
    order.partner = payOrder.partnerID;
    order.seller  = payOrder.sellerID;
    order.tradeNO = payOrder.out_no;
//    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
	order.productName = payOrder.subject; //商品标题
	order.productDescription = payOrder.body; //商品描述
	order.amount = [NSString stringWithFormat:@"%.2f",payOrder.price]; //商品价格
	
    order.notifyURL =  notifyURL; //回调URL
	
	return [order description];
}

////生成唯一订单号
//+ (NSString *)generateTradeNO
//{
//	const int N = 15;
//	
//	NSString *sourceString = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
//	NSMutableString *result = [[NSMutableString alloc] init] ;
//	srand(time(0));
//	for (int i = 0; i < N; i++)
//	{
//		unsigned index = rand() % [sourceString length];
//		NSString *s = [sourceString substringWithRange:NSMakeRange(index, 1)];
//		[result appendString:s];
//	}
//	return result;
//}

+ (NSString*)doRsa:(NSString*)orderInfo andKey:(NSString *)key
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(key);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}

@end
