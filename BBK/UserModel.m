//
//  UserModel.m
//  zhxq
//
//  Created by Seven on 13-9-21.
//
//

#import "UserModel.h"
#import "AESCrypt.h"

@implementation UserModel

@synthesize topicTitle;
@synthesize topicContent;
@synthesize isNetworkRunning;

static UserModel * instance = nil;
+(UserModel *) Instance
{
    @synchronized(self)
    {
        if(nil == instance)
        {
            [self new];
        }
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

-(void)saveIsLogin:(BOOL)_isLogin
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"isLogin"];
    [user setObject:_isLogin ? @"1" : @"0" forKey:@"isLogin"];
    [user synchronize];
}

-(BOOL)isLogin
{
    @try {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString * value = [user objectForKey:@"isLogin"];
        if (value && [value isEqualToString:@"1"]) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    @catch (NSException *exception) {
        [NdUncaughtExceptionHandler TakeException:exception];
    }
}

-(void)saveAccount:(NSString *)account andPwd:(NSString *)pwd
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    [user removeObjectForKey:@"Account"];
    [user setObject:account forKey:@"Account"];
    
    [user removeObjectForKey:@"Password"];
    pwd = [AESCrypt encrypt:pwd password:@"pwd"];
    [user setObject:pwd forKey:@"Password"];
    
    [user synchronize];
}

-(NSString *)getPwd
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString * temp = [user objectForKey:@"Password"];
    return [AESCrypt decrypt:temp password:@"pwd"];
}

-(NSString *)getUserValueForKey:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:key];
}

-(void)removeUserValueForKey:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:key];
    [user synchronize];
}

-(void)saveValue:(NSString *)value ForKey:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:key];
    [user setObject:value forKey:key];
    [user synchronize];
}

-(NSString *)getIOSGuid
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString * value = [settings objectForKey:@"guid"];
    if (value && [value isEqualToString:@""] == NO) {
        return value;
    }
    else
    {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString * uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        [settings setObject:uuidString forKey:@"guid"];
        [settings synchronize];
        return uuidString;
    }
}

@end
