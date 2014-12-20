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
#import "SuitType.h"
#import "Suit.h"
#import "SuitBasic.h"
#import "SuitReply.h"
#import "SuitResult.h"
#import "SuitResultItem.h"
#import "BorrowRecord.h"
#import "PassInfo.h"
#import "Activity.h"
#import "TopicFull.h"
#import "TopicReply.h"
#import "TopicType.h"
#import "Payment.h"
#import "PaymentItem.h"

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
/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+ (float)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width;

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
//解析物品借用记录JSON
+ (NSMutableArray *)readJsonStrToBorrowRecordsArray:(NSString *)str;
//获得未收包裹数量
+ (NSString *)readJsonStrToExpressNum:(NSString *)str;
//解析快递包裹JSON
+ (NSMutableArray *)readJsonStrToExpressArray:(NSString *)str;
//解析社区朋友圈
+ (NSMutableArray *)readJsonStrToTopicArray:(NSString *)str;
//解析社区朋友圈（带评论）
+ (NSMutableArray *)readJsonStrToTopicFullArray:(NSString *)str;
//解析朋友圈类型JSON
+ (NSMutableArray *)readJsonStrToTopicTypeArray:(NSString *)str;
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
//解析投诉类型JSON
+ (NSMutableArray *)readJsonStrToSuitTypeArray:(NSString *)str;
//解析投诉列表JSON
+ (NSMutableArray *)readJsonStrToSuitArray:(NSString *)str;
//解析投诉详情JSON
+ (NSMutableArray *)readJsonStrToSuitItemArray:(NSString *)str;
//解析访客通行证列表JSON
+ (NSMutableArray *)readJsonStrToPassInfoArray:(NSString *)str;
//解析社区活动JSON
+ (NSMutableArray *)readJsonStrToActivityArray:(NSString *)str;
//解析账单列表列表JSON
+ (NSMutableArray *)readJsonStrToPaymentArray:(NSString *)str;
//解析月账单明细JSON
+ (NSMutableArray *)readJsonStrToPaymentItemArray:(NSString *)str;

@end
