//
//  UIDevice+ID.h
//  Extentions
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIDevice (Extensions)

/*
 * 设备标识，全球惟一
 * iOS6.0以下使用网卡MAC地址生成，6.0及以上使用identifierForVendor
 */

- (NSString *)uniqueIdentifier;

@end
