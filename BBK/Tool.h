//
//  Tool.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonCryptor.h>
#import "RMMapper.h"
#import <CommonCrypto/CommonDigest.h>
#import "UserInfo.h"
#import "UserHouse.h"
#import "City.h"
#import "Community.h"
#import "Building.h"
#import "Unit.h"
#import "HouseNum.h"
#import "Notice.h"
#import "CallService.h"
#import "BorrowGood.h"
#import "Express.h"
#import "Topic.h"
#import "RepairType.h"
#import "Repair.h"
#import "ADInfo.h"
#import "LifeRefer.h"
#import "ShopType.h"
#import "ShopInfo.h"
#import "RepairBasic.h"
#import "RepairDispatch.h"
#import "RepairFinish.h"
#import "RepairResult.h"
#import "RepairResuleItem.h"
#import "Monthly.h"

@interface Tool : NSObject

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message;

+ (NSMutableArray *)getRelativeNews:(NSString *)request;
+ (NSString *)generateRelativeNewsString:(NSArray *)array;

+ (UIColor *)getColorForCell:(int)row;
+ (UIColor *)getColorForMain;

+ (void)clearWebViewBackground:(UIWebView *)webView;

+ (void)doSound:(id)sender;

+ (NSString *)getBBSIndex:(int)index;

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom;

+ (void)borderView:(UIView *)view;
+ (void)roundTextView:(UIView *)txtView andBorderWidth:(float)width andCornerRadius:(float)radius;
+ (void)roundView:(UIView *)view andCornerRadius:(float)radius;

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title;

+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent;

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog;

+ (void)playAudio:(BOOL)isAlert;

+ (NSString *)intervalSinceNow: (NSString *) theDate;

+ (BOOL)isToday:(NSString *) theDate;

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day;

+ (NSString *)getAppClientString:(int)appClient;

+ (void)ReleaseWebView:(UIWebView *)webView;

+ (int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt;
+ (int)getTextHeight:(int)width andUIFont:(UIFont *)font andText:(NSString *)txt;

+ (UIColor *)getBackgroundColor;
+ (UIColor *)getCellBackgroundColor;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(int)type andID:(int)_id;

+ (void)deleteAllCache;

+ (NSString *)getHTMLString:(NSString *)html;

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;
+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second;

+ (UIImage *) scale:(UIImage *)sourceImg toSize:(CGSize)size;

+ (CGSize)scaleSize:(CGSize)sourceSize;

+ (NSString *)getOSVersion;

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom;

+ (void)CancelRequest:(ASIFormDataRequest *)request;

+ (NSDate *)NSStringDateToNSDate:(NSString *)string;
//时间戳转指定格式时间字符串
+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter;

+ (NSString *)GenerateTags:(NSMutableArray *)tags;

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id;
//保留数值几位小数
+ (NSString *)notRounding:(float)price afterPoint:(int)position;

//平台接口生成验签
+ (NSDictionary *)parseQueryString:(NSString *)query;
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params;
//平台接口生成验签Sign中文转UFT-8
+ (NSString *)serializeUFT8Sign:(NSString *)baseURL params:(NSDictionary *)params;
//平台接口生成验签Sign中文
+ (NSString *)serializeSign:(NSString *)baseURL params:(NSDictionary *)params;

//解析登陆JSON
+ (UserInfo *)readJsonStrToLoginUserInfo:(NSString *)str;
//解析城市JSON
+ (NSMutableArray *)readJsonStrToCityArray:(NSString *)str;
//解析社区JSON（包含社区、楼栋、门牌）
+ (NSMutableArray *)readJsonStrToCommunityArray:(NSString *)str;
//解析小区通知JSON
+ (NSMutableArray *)readJsonStrToNoticeArray:(NSString *)str;
//解析物业呼叫JSON
+ (NSMutableArray *)readJsonStrToServiceArray:(NSString *)str;
//解析物品借用JSON
+ (NSMutableArray *)readJsonStrToBorrowGoodsArray:(NSString *)str;
//获得未收包裹数量
+ (NSString *)readJsonStrToExpressNum:(NSString *)str;
//解析快递包裹JSON
+ (NSMutableArray *)readJsonStrToExpressArray:(NSString *)str;
//解析社区朋友圈
+ (NSMutableArray *)readJsonStrToTopicArray:(NSString *)str;
//解析报修类型JSON
+ (NSMutableArray *)readJsonStrToRepairTypeArray:(NSString *)str;
//解析报修列表JSON
+ (NSMutableArray *)readJsonStrToRepairArray:(NSString *)str;
//解析广告JSON
+ (NSMutableArray *)readJsonStrToAdinfoArray:(NSString *)str;
//解析生活查询JSON
+ (NSMutableArray *)readJsonStrToLifeReferArray:(NSString *)str;
//解析商家分类JSON
+ (NSMutableArray *)readJsonStrToShopTypeArray:(NSString *)str;
//解析商家信息JSON
+ (NSMutableArray *)readJsonStrToShopInfoArray:(NSString *)str;
//解析报修详情JSON
+ (NSMutableArray *)readJsonStrToRepairItemArray:(NSString *)str;
//解析悦月刊JSON
+ (NSMutableArray *)readJsonStrToMonthlyArray:(NSString *)str;

@end
