//
//  NSString+AES.h
//  Flight
//
//  Created by majianglin on 13-5-27.
//  Copyright (c) 2013年 totemtec.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AES)

- (NSString*)AES256EncryptWithKey:(NSString*)key;

@end

@interface NSData(HEX)

- (NSString*)hexString;

@end
