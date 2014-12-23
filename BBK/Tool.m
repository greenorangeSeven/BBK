//
//  Tool.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *progressAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(121, 80, 37, 37);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

+ (NSString *)getBBSIndex:(int)index
{
    if (index < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d楼", index+1];
}

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom
{
    if (isBottom) {
        NSUInteger sectionCount = [tableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [tableView numberOfRowsInSection:0];
            if (rowCount) {
                NSUInteger ii[2] = {0, rowCount - 1};
                NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:isBottom ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    else
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog
{
    switch (catalog) {
        case 1:
        case 3:
            return @"请先登录后发表评论";
        case 2:
            return @"请先登录后再回帖或评论";
        case 4:
            return @"请先登录后发留言";
    }
    return @"请先登录后发表评论";
}

+ (void)borderView:(UIView *)view
{
    view.layer.borderColor = [[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] CGColor];
    view.layer.borderWidth = 1;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+ (void)roundTextView:(UIView *)txtView andBorderWidth:(float)width andCornerRadius:(float)radius
{
    txtView.layer.borderColor = [[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0] CGColor];
    txtView.layer.borderWidth = width;
    txtView.layer.cornerRadius = radius;
    txtView.layer.masksToBounds = YES;
    txtView.clipsToBounds = YES;
}

+ (void)roundView:(UIView *)view andCornerRadius:(float)radius
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+ (void)playAudio:(BOOL)isAlert
{
    NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath], isAlert ? @"/alertsound.wav" : @"/soundeffect.wav"];
    SystemSoundID soundID;
    NSURL * filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (UIColor *)getColorForCell:(int)row
{
    return row % 2 ?
    [UIColor colorWithRed:235.0/255.0 green:242.0/255.0 blue:252.0/255.0 alpha:1.0]:
    [UIColor colorWithRed:248.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (UIColor *)getColorForMain
{
    return [UIColor colorWithRed:0.90 green:0.47 blue:0.10 alpha:1.0];
}

+ (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}

+ (void)doSound:(id)sender
{
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"soundeffect" ofType:@"wav"]] error:&err];
    player.volume = 1;
    player.numberOfLoops = 1;
    [player prepareToPlay];
    [player play];
}

+ (NSString *)getAppClientString:(int)appClient
{
    switch (appClient) {
        case 1:
            return @"";
        case 2:
            return @"来自手机";
        case 3:
            return @"来自手机";
        case 4:
            return @"来自iPhone";
        case 5:
            return @"来自手机";
        default:
            return @"";
    }
}

+ (void)ReleaseWebView:(UIWebView *)webView
{
    [webView stopLoading];
    [webView setDelegate:nil];
    webView = nil;
}

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请先登录或注册" delegate:delegate cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", @"注册", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}
+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent
{
    //    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    //    if ([buttonTitle isEqualToString:@"登录"]) {
    //        LoginView *loginView = [[LoginView alloc] init];
    //        [nav pushViewController:loginView animated:YES];
    //    }
    //    else if([buttonTitle isEqualToString:@"注册"])
    //    {
    //        RegisterView *regView = [[RegisterView alloc] init];
    //        [nav pushViewController:regView animated:YES];
    //    }
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    else
    {
        //        timeString = [NSString stringWithFormat:@"%d-%"]
        NSArray *array = [theDate componentsSeparatedByString:@" "];
        //        return [array objectAtIndex:0];
        timeString = [array objectAtIndex:0];
    }
    return timeString;
}

+ (BOOL)isToday:(NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSTimeInterval cha=now-late;
    
    if (cha/86400<1) {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt
{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(txtView.contentSize.width - 10 - fPadding, CGFLOAT_MAX);
    CGSize size = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight = size.height + 16.0;
    return fHeight;
}

- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

+(int)getTextHeight:(int)width andUIFont:(UIFont *)font andText:(NSString *)txt
{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(width - 10 - fPadding, CGFLOAT_MAX);
    CGSize size = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight = size.height + 16.0;
    return fHeight;
}

/**
 @method 获取指定宽度情况ixa，字符串value的高度
 @param value 待计算的字符串
 @param fontSize 字体的大小
 @param andWidth 限制字符串显示区域的宽度
 @result float 返回的高度
 */
+ (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width - 16, CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    return sizeToFit.height;
}

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day
{
    return year*365 + month * 31 + day;
}

+ (UIColor *)getBackgroundColor
{
    //    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"fb_bg.jpg"]];
    return [UIColor colorWithRed:234.0/255 green:234.0/255 blue:234.0/255 alpha:1.0];
}
+ (UIColor *)getCellBackgroundColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (void)deleteAllCache
{
}

+ (NSString *)getHTMLString:(NSString *)html
{
    return html;
}
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
    //    hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}

+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]] ;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD show:YES];
    [HUD hide:YES afterDelay:second];
}

+ (UIImage *)scale:(UIImage *)sourceImg toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    }
    else
    {
        return CGSizeMake(800 * width / height, 800);
    }
}

+ (NSString *)getOSVersion
{
    return [NSString stringWithFormat:@"GreenOrange.com/%@/%@/%@/%@",AppVersion,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion, [UIDevice currentDevice].model];
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom
{
    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:isLoading inPresentationMode:isBottom?GCDiscreetNotificationViewPresentationModeBottom:GCDiscreetNotificationViewPresentationModeTop inView:view];
    [notificationView show:YES];
    [notificationView hideAnimatedAfter:2.6];
}
+ (void)CancelRequest:(ASIHTTPRequest *)request
{
    if (request != nil) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
}
+ (NSDate *)NSStringDateToNSDate:(NSString *)string
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * d = [f dateFromString:string];
    return d;
}

+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
    return [dateFormatter stringFromDate:confromTimesp];
}

+ (NSString *)GenerateTags:(NSMutableArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    }
    else
    {
        NSString *result = @"";
        for (NSString *t in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;",result,t,t];
        }
        return result;
    }
}

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (NSString *)notRounding:(float)price afterPoint:(int)position
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

//平台接口生成验签
+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        if ([elements count] <= 1) {
            return nil;
        }
        
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

//平台接口生成验签
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:[NSString stringWithFormat:@"accessId%@", Appkey]];
    NSMutableString *paramsString = [NSMutableString stringWithFormat:@"accessId=%@", Appkey];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys) {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
        [paramsString appendFormat:@"&%@=%@", key, [paramsDic objectForKey:key]];
    }
    [signString appendString:AppSecret];
    NSString *signStringUTF8 = [signString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signStringUTF8 dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        [paramsString appendFormat:@"&sign=%@", [digestString lowercaseString]];
        return [NSString stringWithFormat:@"%@://%@:%@%@?%@", [parsedURL scheme], [parsedURL host], [parsedURL port], [parsedURL path], [paramsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        return nil;
    }
}

//平台接口生成验签Sign中文转UFT-8
+ (NSString *)serializeUFT8Sign:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:[NSString stringWithFormat:@"accessId%@", Appkey]];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys) {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
    }
    [signString appendString:AppSecret];
    NSString *signStringUTF8 = [signString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signStringUTF8 dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        return [digestString lowercaseString];
    } else {
        return nil;
    }
}

//平台接口生成验签Sign中文
+ (NSString *)serializeSign:(NSString *)baseURL params:(NSDictionary *)params
{
    NSURL* parsedURL = [NSURL URLWithString:[baseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:[self parseQueryString:[parsedURL query]]];
    if (params) {
        [paramsDic setValuesForKeysWithDictionary:params];
    }
    
    NSMutableString *signString = [NSMutableString stringWithString:[NSString stringWithFormat:@"accessId%@", Appkey]];
    NSArray *sortedKeys = [[paramsDic allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSString *key in sortedKeys) {
        [signString appendFormat:@"%@%@", key, [paramsDic objectForKey:key]];
    }
    [signString appendString:AppSecret];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    NSData *stringBytes = [signString dataUsingEncoding: NSUTF8StringEncoding];
    if (CC_MD5([stringBytes bytes], [stringBytes length], digest)) {
        /* SHA-1 hash has been calculated and stored in 'digest'. */
        NSMutableString *digestString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
            unsigned char aChar = digest[i];
            [digestString appendFormat:@"%02X", aChar];
        }
        return [digestString lowercaseString];
    } else {
        return nil;
    }
}

//解析登陆JSON
+ (UserInfo *)readJsonStrToLoginUserInfo:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *userJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( userJsonDic == nil || [userJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[userJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSDictionary *userInfoDic = [userJsonDic objectForKey:@"data"];
        UserInfo *userInfo = [RMMapper objectWithClass:[UserInfo class] fromDictionary:userInfoDic];
        NSMutableArray *rhUserHouseList = [RMMapper mutableArrayOfClass:[UserHouse class] fromArrayOfDictionary:[userInfoDic objectForKey:@"rhUserHouseList"]];
        userInfo.rhUserHouseList = rhUserHouseList;
        return userInfo;
    }
    else
    {
        return nil;
    }
}

//解析城市JSON
+ (NSMutableArray *)readJsonStrToCityArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *cityJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( cityJsonDic == nil || [cityJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[cityJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *cityArrayJson = [cityJsonDic objectForKey:@"data"];
        NSMutableArray *cityArray = [RMMapper mutableArrayOfClass:[City class] fromArrayOfDictionary:cityArrayJson];
        return cityArray;
    }
    else
    {
        return nil;
    }
}

//解析社区JSON（包含社区、楼栋、门牌）
+ (NSMutableArray *)readJsonStrToCommunityArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *communityJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( communityJsonDic == nil || [communityJsonDic count] <= 0) {
        return nil;
    }
    NSArray *communityArrayJson = [communityJsonDic objectForKey:@"data"];
    NSMutableArray *communityArray = [RMMapper mutableArrayOfClass:[Community class] fromArrayOfDictionary:communityArrayJson];
    for (Community *comu in communityArray) {
        NSArray *comuSubList = comu.subList;
        comu.buildingList = [RMMapper mutableArrayOfClass:[Building class] fromArrayOfDictionary:comuSubList];
        for (Building *building in comu.buildingList) {
            NSArray *buildingSubList = building.subList;
            building.unitList = [RMMapper mutableArrayOfClass:[Unit class] fromArrayOfDictionary:buildingSubList];
            for (Unit *unit in building.unitList) {
                NSArray *unitSubList = unit.subList;
                unit.houseNumList = [RMMapper mutableArrayOfClass:[HouseNum class] fromArrayOfDictionary:unitSubList];
            }
        }
    }
    return communityArray;
}

//解析小区通知JSON
+ (NSMutableArray *)readJsonStrToNoticeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *noticeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( noticeJsonDic == nil || [noticeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[noticeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *noticeArrayJson = [[noticeJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *noticeArray = [RMMapper mutableArrayOfClass:[Notice class] fromArrayOfDictionary:noticeArrayJson];
        for (Notice *n in noticeArray) {
            n.starttime = [self TimestampToDateStr:n.starttimeStamp andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        }
        return noticeArray;
    }
    else
    {
        return nil;
    }
}

//解析物业呼叫JSON
+ (NSMutableArray *)readJsonStrToServiceArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *serviceJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( serviceJsonDic == nil || [serviceJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[serviceJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *serviceArrayJson = [serviceJsonDic objectForKey:@"data"];
        NSMutableArray *serviceArray = [RMMapper mutableArrayOfClass:[CallService class] fromArrayOfDictionary:serviceArrayJson];
        return serviceArray;
    }
    else
    {
        return nil;
    }
}

//解析物品借用JSON
+ (NSMutableArray *)readJsonStrToBorrowGoodsArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *goodsJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( goodsJsonDic == nil || [goodsJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[goodsJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *goodsArrayJson = [[goodsJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *goodsArray = [RMMapper mutableArrayOfClass:[BorrowGood class] fromArrayOfDictionary:goodsArrayJson];
        for (BorrowGood *good in goodsArray) {
            good.imgUrlFull = [NSString stringWithFormat:@"%@_200", good.imgUrlFull];
        }
        return goodsArray;
    }
    else
    {
        return nil;
    }
}

//解析物品借用记录JSON
+ (NSMutableArray *)readJsonStrToBorrowRecordsArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *recordJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( recordJsonDic == nil || [recordJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[recordJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *recordArrayJson = [recordJsonDic objectForKey:@"data"];
        NSMutableArray *recordArray = [RMMapper mutableArrayOfClass:[BorrowRecord class] fromArrayOfDictionary:recordArrayJson];
        for (BorrowRecord *borrowRecord in recordArray) {
            borrowRecord.starttime = [Tool TimestampToDateStr:borrowRecord.starttimeStamp andFormatterStr:@"yyyy-MM-dd HH:mm:ss"];
        }
        
        return recordArray;
    }
    else
    {
        return nil;
    }
}

//获得未收包裹数量
+ (NSString *)readJsonStrToExpressNum:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *expressJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( expressJsonDic == nil || [expressJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[expressJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES)
    {
        NSString *expressNum = [NSString stringWithFormat:@"%d", [[[expressJsonDic objectForKey:@"data"] objectForKey:@"totalRecord"] intValue]] ;
        return expressNum;
    }
    else
    {
        return @"0";
    }
}

//解析快递包裹JSON
+ (NSMutableArray *)readJsonStrToExpressArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *expressJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( expressJsonDic == nil || [expressJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[expressJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *expressArrayJson = [[expressJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *expressArray = [RMMapper mutableArrayOfClass:[Express class] fromArrayOfDictionary:expressArrayJson];
        for (Express *exp in expressArray) {
            exp.timeDiff = [Tool intervalSinceNow:[Tool TimestampToDateStr:[exp.starttimeStamp stringValue] andFormatterStr:@"yyyy-MM-dd HH:mm:ss"]];
        }
        return expressArray;
    }
    else
    {
        return nil;
    }
}

//解析社区朋友圈
+ (NSMutableArray *)readJsonStrToTopicArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *topicJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( topicJsonDic == nil || [topicJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[topicJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *topicArrayJson = [[topicJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *topicArray = [RMMapper mutableArrayOfClass:[Topic class] fromArrayOfDictionary:topicArrayJson];
        for (Topic *exp in topicArray) {
            exp.starttime = [Tool intervalSinceNow:[Tool TimestampToDateStr:[exp.starttimeStamp stringValue] andFormatterStr:@"yyyy-MM-dd HH:mm:ss"]];
            exp.contentHeight = [self heightForString:exp.content fontSize:14.0 andWidth:236.0];
            //            exp.contentHeight = [self getTextHeight:236 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:exp.content];
            if (exp.contentHeight < 21)
            {
                exp.contentHeight = 21;
            }
            else
            {
                exp.contentHeight -= 10;
            }
            int imgCount = [exp.imgUrlList count];
            if (imgCount > 0) {
                int row = 0;
                if (imgCount % 3 > 0) {
                    row = imgCount / 3 + 1;
                }
                else
                {
                    row = imgCount / 3;
                }
                exp.imageViewHeight = 70 * row;
            }
            else
            {
                exp.imageViewHeight = 0;
            }
            
            if (exp.contentHeight > 30) {
                exp.viewAddHeight += exp.contentHeight - 21;
            }
            if (exp.imageViewHeight > 70) {
                exp.viewAddHeight += exp.imageViewHeight - 70;
            }
        }
        return topicArray;
    }
    else
    {
        return nil;
    }
}

//解析社区朋友圈（带评论）
+ (NSMutableArray *)readJsonStrToTopicFullArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *topicJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( topicJsonDic == nil || [topicJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[topicJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *topicArrayJson = [[topicJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *topicArray = [RMMapper mutableArrayOfClass:[TopicFull class] fromArrayOfDictionary:topicArrayJson];
        for (TopicFull *topic in topicArray) {
            topic.replyList = [RMMapper mutableArrayOfClass:[TopicReply class] fromArrayOfDictionary:topic.replyList];
            topic.replyHeight = 0;
            for(TopicReply *reply in topic.replyList)
            {
                reply.replyContent = [NSString stringWithFormat:@"%@：%@",reply.nickName, reply.replyContent];
                reply.contentHeight = [self heightForString:reply.replyContent fontSize:14.0 andWidth:232.0] + 3;
                topic.replyHeight += reply.contentHeight;
                
                reply.replyContentAttr = [[NSMutableAttributedString alloc] initWithString:reply.replyContent];
                [reply.replyContentAttr addAttribute:NSForegroundColorAttributeName value:[Tool getColorForMain] range:NSMakeRange(0, [reply.nickName length] + 1)];
            }
            
            topic.starttime = [Tool intervalSinceNow:[Tool TimestampToDateStr:topic.starttimeStamp  andFormatterStr:@"yyyy-MM-dd HH:mm:ss"]];
            topic.contentHeight = [self heightForString:topic.content fontSize:14.0 andWidth:236.0];
            
            if (topic.contentHeight < 21)
            {
                topic.contentHeight = 21;
            }
            else
            {
                topic.contentHeight -= 10;
            }
            int imgCount = [topic.imgUrlList count];
            if (imgCount > 0) {
                int row = 0;
                if (imgCount % 3 > 0) {
                    row = imgCount / 3 + 1;
                }
                else
                {
                    row = imgCount / 3;
                }
                topic.imageViewHeight = 70 * row;
            }
            else
            {
                topic.imageViewHeight = 0;
            }
            
            
            topic.viewAddHeight += topic.contentHeight;
            
            topic.viewAddHeight += topic.imageViewHeight;
            
            topic.viewAddHeight += topic.replyHeight;
        }
        return topicArray;
    }
    else
    {
        return nil;
    }
}

//解析朋友圈类型JSON
+ (NSMutableArray *)readJsonStrToTopicTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *typeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( typeJsonDic == nil || [typeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[typeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *typeArrayJson = [typeJsonDic objectForKey:@"data"];
        NSMutableArray *typeArray = [RMMapper mutableArrayOfClass:[TopicType class] fromArrayOfDictionary:typeArrayJson];
        return typeArray;
    }
    else
    {
        return nil;
    }
}

//解析报修类型JSON
+ (NSMutableArray *)readJsonStrToRepairTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *typeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( typeJsonDic == nil || [typeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[typeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *typeArrayJson = [typeJsonDic objectForKey:@"data"];
        NSMutableArray *typeArray = [RMMapper mutableArrayOfClass:[RepairType class] fromArrayOfDictionary:typeArrayJson];
        return typeArray;
    }
    else
    {
        return nil;
    }
}

//解析报修列表JSON
+ (NSMutableArray *)readJsonStrToRepairArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *repairJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( repairJsonDic == nil || [repairJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[repairJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *repairArrayJson = [[repairJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *repairArray = [RMMapper mutableArrayOfClass:[Repair class] fromArrayOfDictionary:repairArrayJson];
        for (Repair *r in repairArray) {
            r.starttime = [self TimestampToDateStr:r.starttimeStamp andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        }
        return repairArray;
    }
    else
    {
        return nil;
    }
}

//解析广告JSON
+ (NSMutableArray *)readJsonStrToAdinfoArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *adJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( adJsonDic == nil || [adJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[adJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *adArrayJson = [adJsonDic objectForKey:@"data"];
        NSMutableArray *adArray = [RMMapper mutableArrayOfClass:[ADInfo class] fromArrayOfDictionary:adArrayJson];
        return adArray;
    }
    else
    {
        return nil;
    }
}

//解析生活查询JSON
+ (NSMutableArray *)readJsonStrToLifeReferArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *referJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( referJsonDic == nil || [referJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[referJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *referArrayJson = [referJsonDic objectForKey:@"data"];
        NSMutableArray *referArray = [RMMapper mutableArrayOfClass:[LifeRefer class] fromArrayOfDictionary:referArrayJson];
        return referArray;
    }
    else
    {
        return nil;
    }
}

//解析商家分类JSON
+ (NSMutableArray *)readJsonStrToShopTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *shopTypeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( shopTypeJsonDic == nil || [shopTypeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[shopTypeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *shopTypeArrayJson = [shopTypeJsonDic objectForKey:@"data"];
        NSMutableArray *shopTypeArray = [RMMapper mutableArrayOfClass:[ShopType class] fromArrayOfDictionary:shopTypeArrayJson];
        return shopTypeArray;
    }
    else
    {
        return nil;
    }
}

//解析商家信息JSON
+ (NSMutableArray *)readJsonStrToShopInfoArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *shopInfoJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( shopInfoJsonDic == nil || [shopInfoJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[shopInfoJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *shopInfoArrayJson = [[shopInfoJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *shopInfoArray = [RMMapper mutableArrayOfClass:[ShopInfo class] fromArrayOfDictionary:shopInfoArrayJson];
        for (ShopInfo *shop in shopInfoArray) {
            shop.imgUrlFull = [NSString stringWithFormat:@"%@_200", shop.imgUrlFull];
        }
        return shopInfoArray;
    }
    else
    {
        return nil;
    }
}

//解析报修详情JSON
+ (NSMutableArray *)readJsonStrToRepairItemArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *repairDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( repairDic == nil || [repairDic count] <= 0) {
        return nil;
    }
    NSString *state = [[repairDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        NSDictionary *repairDicJson = [repairDic objectForKey:@"data"];
        //        NSMutableArray *serviceArray = [RMMapper mutableArrayOfClass:[CallService class] fromArrayOfDictionary:repairDicJson];
        RepairBasic *basic = [RMMapper objectWithClass:[RepairBasic class] fromDictionary:repairDicJson];
        basic.starttime = [self TimestampToDateStr:[basic.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        basic.contentHeight = [self getTextHeight:304 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:basic.repairContent];
        if (basic.contentHeight < 36)
        {
            basic.contentHeight = 36;
            basic.viewAddHeight = 0;
        }
        else
        {
            basic.viewAddHeight = basic.contentHeight - 36;
        }
        //添加报修基础数据
        [items addObject:basic];
        basic.fullImgList = [[NSMutableArray alloc] init];
        for (int i = 0; i < [basic.imgList count]; i++) {
            NSDictionary *imageDicJson = [basic.imgList objectAtIndex:i];
            [basic.fullImgList addObject:[imageDicJson objectForKey:@"imgUrlFull"]];
        }
        for (int l = 0; l < [basic.repairRunList count]; l++) {
            if (l == 0) {
                RepairDispatch *dispatch = [[RepairDispatch alloc] init];
                dispatch.repairmanId = basic.repairmanId;
                dispatch.repairmanName = basic.repairmanName;
                dispatch.mobileNo = basic.mobileNo;
                dispatch.starttimeStamp = [[basic.repairRunList objectAtIndex:l] objectForKey:@"starttimeStamp"];
                dispatch.starttime = [self TimestampToDateStr:[dispatch.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
                //添加报修派单数据
                [items addObject:dispatch];
            }
            if (l == 1) {
                RepairFinish *finish = [[RepairFinish alloc] init];
                finish.runContent = [[basic.repairRunList objectAtIndex:l] objectForKey:@"runContent"];
                finish.cost = basic.cost;
                finish.starttimeStamp = [[basic.repairRunList objectAtIndex:l] objectForKey:@"starttimeStamp"];
                finish.starttime = [self TimestampToDateStr:[finish.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
                
                finish.contentHeight = [self getTextHeight:304 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:finish.runContent];
                if (finish.contentHeight < 36)
                {
                    finish.contentHeight = 36;
                    finish.viewAddHeight = 0;
                }
                else
                {
                    finish.viewAddHeight = finish.contentHeight - 36;
                }
                
                //添加维修完成数据
                [items addObject:finish];
            }
        }
        if ([items count] >= 3 && [basic.repairResult count] > 0) {
            RepairResult *result = [[RepairResult alloc] init];
            result.repairResult = [RMMapper mutableArrayOfClass:[RepairResuleItem class] fromArrayOfDictionary:basic.repairResult];
            result.userRecontent = basic.userRecontent;
            result.scoreViewHeight = 39 * [result.repairResult count];
            result.addViewHeight = 39 * ([result.repairResult count] - 1);
            //添加维修评论数据
            [items addObject:result];
        }
        
        return items;
    }
    else
    {
        return nil;
    }
}

//解析悦月刊JSON
+ (NSMutableArray *)readJsonStrToMonthlyArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *monthlyJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( monthlyJsonDic == nil || [monthlyJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[monthlyJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *monthlyArrayJson = [[monthlyJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *monthlyArray = [RMMapper mutableArrayOfClass:[Monthly class] fromArrayOfDictionary:monthlyArrayJson];
        return monthlyArray;
    }
    else
    {
        return nil;
    }
}

//解析投诉类型JSON
+ (NSMutableArray *)readJsonStrToSuitTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *typeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( typeJsonDic == nil || [typeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[typeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *typeArrayJson = [typeJsonDic objectForKey:@"data"];
        NSMutableArray *typeArray = [RMMapper mutableArrayOfClass:[SuitType class] fromArrayOfDictionary:typeArrayJson];
        return typeArray;
    }
    else
    {
        return nil;
    }
}

//解析投诉列表JSON
+ (NSMutableArray *)readJsonStrToSuitArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *suitJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( suitJsonDic == nil || [suitJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[suitJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *suitArrayJson = [[suitJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *suitArray = [RMMapper mutableArrayOfClass:[Suit class] fromArrayOfDictionary:suitArrayJson];
        for (Suit *s in suitArray) {
            s.starttime = [self TimestampToDateStr:[s.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        }
        return suitArray;
    }
    else
    {
        return nil;
    }
}

//解析投诉详情JSON
+ (NSMutableArray *)readJsonStrToSuitItemArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *suitDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( suitDic == nil || [suitDic count] <= 0) {
        return nil;
    }
    NSString *state = [[suitDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        NSDictionary *suitDicJson = [suitDic objectForKey:@"data"];
        
        SuitBasic *basic = [RMMapper objectWithClass:[SuitBasic class] fromDictionary:suitDicJson];
        basic.starttime = [self TimestampToDateStr:[basic.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        basic.contentHeight = [self getTextHeight:304 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:basic.suitContent];
        if (basic.contentHeight < 36)
        {
            basic.contentHeight = 36;
            basic.viewAddHeight = 0;
        }
        else
        {
            basic.viewAddHeight = basic.contentHeight - 36;
        }
        //将图片对象转图片数组
        basic.fullImgList = [[NSMutableArray alloc] init];
        for (int i = 0; i < [basic.imgList count]; i++) {
            NSDictionary *imageDicJson = [basic.imgList objectAtIndex:i];
            [basic.fullImgList addObject:[imageDicJson objectForKey:@"imgUrlFull"]];
        }
        //添加投诉基础数据
        [items addObject:basic];
        if (basic.suitReply != nil) {
            basic.suitReply.replyTime = [self TimestampToDateStr:[basic.suitReply.replyTimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
            basic.suitReply.contentHeight = [self getTextHeight:304 andUIFont:[UIFont fontWithName:@"Arial-BoldItalicMT" size:14] andText:basic.suitReply.replyContent];
            if (basic.suitReply.contentHeight < 36)
            {
                basic.suitReply.contentHeight = 36;
                basic.suitReply.viewAddHeight = 0;
            }
            else
            {
                basic.suitReply.viewAddHeight = basic.suitReply.contentHeight - 36;
            }
            //添加投诉反馈数据
            [items addObject:basic.suitReply];
        }
        if ([items count] >= 2 && [basic.suitResult count] > 0) {
            SuitResult *result = [[SuitResult alloc] init];
            result.suitResult = [RMMapper mutableArrayOfClass:[SuitResultItem class] fromArrayOfDictionary:basic.suitResult];
            result.userRecontent = basic.userRecontent;
            result.scoreViewHeight = 39 * [result.suitResult count];
            result.addViewHeight = 39 * ([result.suitResult count] - 1);
            //添加投诉评论数据
            [items addObject:result];
        }
        
        return items;
    }
    else
    {
        return nil;
    }
}

//解析访客通行证列表JSON
+ (NSMutableArray *)readJsonStrToPassInfoArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *passInfoJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( passInfoJsonDic == nil || [passInfoJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[passInfoJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *passinfoArrayJson = [[passInfoJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *passInfoArray = [RMMapper mutableArrayOfClass:[PassInfo class] fromArrayOfDictionary:passinfoArrayJson];
        for (PassInfo *info in passInfoArray) {
            info.starttime = [self TimestampToDateStr:[info.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日 HH:mm"];
        }
        return passInfoArray;
    }
    else
    {
        return nil;
    }
}

//解析社区活动JSON
+ (NSMutableArray *)readJsonStrToActivityArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *activityJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( activityJsonDic == nil || [activityJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[activityJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *activityArrayJson = [activityJsonDic objectForKey:@"data"];
        NSMutableArray *activityArray = [RMMapper mutableArrayOfClass:[Activity class] fromArrayOfDictionary:activityArrayJson];
        for (Activity *info in activityArray) {
            info.starttime = [self TimestampToDateStr:[info.starttimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日"];
            info.endtime = [self TimestampToDateStr:[info.endtimeStamp stringValue] andFormatterStr:@"yyyy年MM月dd日"];
        }
        return activityArray;
    }
    else
    {
        return nil;
    }
}

//解析账单列表列表JSON
+ (NSMutableArray *)readJsonStrToPaymentArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *paymentJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( paymentJsonDic == nil || [paymentJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[paymentJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *paymentArrayJson = [[paymentJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *paymentArray = [RMMapper mutableArrayOfClass:[Payment class] fromArrayOfDictionary:paymentArrayJson];
        return paymentArray;
    }
    else
    {
        return nil;
    }
}

//解析月账单明细JSON
+ (NSMutableArray *)readJsonStrToPaymentItemArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *itemJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( itemJsonDic == nil || [itemJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[itemJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *itemArrayJson = [itemJsonDic objectForKey:@"data"];
        NSMutableArray *itemArray = [RMMapper mutableArrayOfClass:[PaymentItem class] fromArrayOfDictionary:itemArrayJson];
        for (PaymentItem *item in itemArray) {
            item.dbildate = [self TimestampToDateStr:[item.dbildateStamp stringValue] andFormatterStr:@"yyyy-MM-dd"];
        }
        return itemArray;
    }
    else
    {
        return nil;
    }
}

//解析交易买卖JSON
+ (NSMutableArray *)readJsonStrToTradeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *tradeJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( tradeJsonDic == nil || [tradeJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[tradeJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *tradeArrayJson = [[tradeJsonDic objectForKey:@"data"] objectForKey:@"resultsList"];
        NSMutableArray *tradeArray = [RMMapper mutableArrayOfClass:[Trade class] fromArrayOfDictionary:tradeArrayJson];
        return tradeArray;
    }
    else
    {
        return nil;
    }
}

//解析房间所绑定的用户JSON
+ (NSMutableArray *)readJsonStrToHouseUserArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *userJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( userJsonDic == nil || [userJsonDic count] <= 0) {
        return nil;
    }
    NSString *state = [[userJsonDic objectForKey:@"header"] objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == YES) {
        NSArray *userArrayJson = [userJsonDic objectForKey:@"data"];
        NSMutableArray *userArray = [RMMapper mutableArrayOfClass:[HouseUser class] fromArrayOfDictionary:userArrayJson];
        return userArray;
    }
    else
    {
        return nil;
    }
}

@end
