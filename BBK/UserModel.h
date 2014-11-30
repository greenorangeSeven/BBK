//
//  UserModel.h
//  zhxq
//
//  Created by Seven on 13-9-21.
//
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
+(UserModel *) Instance;
+(id)allocWithZone:(NSZone *)zone;
-(void)saveIsLogin:(BOOL)_isLogin;
-(BOOL)isLogin;

//是否具备网络链接
@property BOOL isNetworkRunning;

-(void)saveAccount:(NSString *)account
             andPwd:(NSString *)pwd;

-(NSString *)getPwd;

-(NSString *)getUserValueForKey:(NSString *)key;
-(void)removeUserValueForKey:(NSString *)key;
-(void)saveValue:(NSString *)value ForKey:(NSString *)key;

//话题缓存
@property (copy,nonatomic) NSString * topicTitle;
@property (copy,nonatomic) NSString * topicContent;

-(NSString *)getIOSGuid;

@end
