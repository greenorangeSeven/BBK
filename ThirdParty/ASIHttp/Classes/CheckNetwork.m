//
//  CheckNetwork.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"

@implementation CheckNetwork
+(BOOL)isExistenceNetwork
{
	BOOL isExistenceNetwork;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.sina.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			isExistenceNetwork=FALSE;
            break;
        case ReachableViaWWAN:
			isExistenceNetwork=TRUE;
            break;
        case ReachableViaWiFi:
			isExistenceNetwork=TRUE;
            break;
    }
	return isExistenceNetwork;
    
    return YES;
}

+(NSString *)networkType
{
	NSString *type;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.sina.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			type=noConnect;
            break;
        case ReachableViaWWAN:
			type=netConnect;
            break;
        case ReachableViaWiFi:
			type=wifi;
            break;
    }
	return type;
}

+ (BOOL)isEnableWIFI{
    return([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G
+ (BOOL)isEnable3G{
    return([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}
@end
