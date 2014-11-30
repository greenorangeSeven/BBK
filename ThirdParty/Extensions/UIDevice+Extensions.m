//
//  UIDevice+ID.m
//  Extentions
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+Extensions.h"
#import "NSString+Extensions.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice(Extensions)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

static NSString *deviceIdentifier;

- (NSString *)uniqueIdentifier
{
    if (deviceIdentifier == nil)
    {
        //iOS 6.0 or later
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)])
        {
            deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
        }
        else
        {
            NSString *macaddress = [[UIDevice currentDevice] macaddress];
            deviceIdentifier = [macaddress MD5String];
        }
    }
    
#if TARGET_IPHONE_SIMULATOR
    
    deviceIdentifier = @"49059036-21B7-4D3F-9766-A1917D7CBC38";
    
#endif
    
    return deviceIdentifier;
}

@end
