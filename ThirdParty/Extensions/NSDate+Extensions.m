//
//  NSDate+Extensions.m
//  star_letv
//
//  Created by Yunfei Bai on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

- (NSDate*)sixMonthsAgo
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -6;
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate*)oneYearAgo
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = -1;
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end
