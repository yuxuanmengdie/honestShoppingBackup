//
//  HSPublic.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSPublic.h"
#import "HSUserInfoModel.h"
#import "MBProgressHUD.h"

#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation HSPublic



#pragma mark 用 RGB 画图

+ (UIImage *) ImageWithColor: (UIColor *)color
{
    CGRect          aFrame = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, aFrame);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;

}


+ (UIImage *) ImageWithColor: (UIColor *) color frame:(CGRect)aFrame
{
    aFrame = CGRectMake(0, 0, aFrame.size.width, aFrame.size.height);
    //    if (CGRectEqualToRect(aFrame, CGRectZero))
    //    {
    //         aFrame = CGRectMake(0, 0, 1, 1);
    //    }
    
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, aFrame);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


//修改图片的尺寸
+ (UIImage*) drawInRectImage:(UIImage*)startImage size:(CGSize)imageSize
{
    float  w = CGImageGetWidth(startImage.CGImage);
    
    float  h = CGImageGetHeight(startImage.CGImage);
    
    float wt = imageSize.width/w;
    
    float ht = imageSize.height/h;
    
    CGRect targetRect;
    
    if (wt<ht) {
        
        targetRect = CGRectMake(0, (imageSize.height-h*wt)/2, imageSize.width, h*wt);
    }else {
        
        targetRect = CGRectMake((imageSize.width-w*ht)/2, 0, w*ht, imageSize.height);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
      CGContextDrawImage(context, targetRect, startImage.CGImage);
    
    CGContextSaveGState(context);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    
    UIImage* resultImage =[UIImage imageWithCGImage:newCGImage];
    
    CGContextRelease(context);
    CGImageRelease(newCGImage);
    
    return  resultImage;
    
}



#pragma mark 添加不要备份 属性
+ (BOOL)addSkipBAckupAttributeItemAtURL:(NSURL *)URL
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
    {
        NSLog(@"%s,file not exsit",__func__);
        return NO;
    }
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    //    BOOL success = NO;
    
    if (!success)
    {
        NSLog(@"%s,faile!,error=%@",__FUNCTION__,error);
    }
    return success;
    
}

+ (BOOL)addSkipBackupAttributeDoc
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *URL = [NSURL fileURLWithPath:doc];
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return success;
}


#pragma mark 判断是否是邮箱
+ (BOOL)isEmaliRegex:(NSString *)email
{
    NSString *red = @"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", red];
    BOOL isMatch = [pred evaluateWithObject:email];
    return isMatch;
}

+ (BOOL)isPhoneNumberRegex:(NSString *)phone
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:phone];
}


#pragma mark md5 加密
///返回 md5
+ (NSString *)md5Str:(NSString *)oriStr
{
    if (oriStr == nil) {
        return nil;
    }
    
    const char *cStr = [oriStr UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); //这里的用法明显是错误的，但是不知道为什么依然可以在网络上得以流传。当srcString中包含空字符（\0）时??????????????????
    //    CC_MD5( cStr, self.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    
    return result;
    
}






#pragma mark 获取ip地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


#pragma mark 字典转str
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    if (dic == nil) {
        return nil;
    }
    NSError *parseError = nil;
    
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    if (jsonData != nil  && parseError == nil) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark  -
#pragma mark 保存用户信息
+ (void)saveUserInfoToPlist:(NSDictionary *)userDic
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",kUserInfoPlistName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    [userDic writeToFile:path atomically:YES];
}

/// 取出用户信息
+ (NSDictionary *)userInfoFromPlist
{
    if (![HSPublic isLoginInStatus]) { /// 不是登录状态
        return nil;
    }
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",kUserInfoPlistName]];

    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    return dic;
}

#pragma mark  -
#pragma mark 登录状态
/// 是否登录状态
+ (BOOL)isLoginInStatus
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *isLogin = [userDefaults objectForKey:kUserIsLoginKey];
    if (isLogin == nil) {
        return NO;
    }
    return isLogin.boolValue;
}

/// 设置登录状态
+ (void)setLoginInStatus:(BOOL)isLogin type:(HSLoginType)type
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:isLogin] forKey:kUserIsLoginKey];
    [userDefaults setObject:[NSNumber numberWithInt:type] forKey:kLoginType];
    [userDefaults synchronize];
}

+ (void)setLoginOut
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:kUserIsLoginKey];
    [userDefaults synchronize];
}

+ (HSLoginType)loginType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *result = [userDefaults objectForKey:kLoginType];
    if (result == nil) {
        return kNoneLoginType;
    }
    
    int type = [result intValue];
    
    return type;
}


+ (void)saveOtherOpenID:(NSString *)openID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[HSPublic controlNullString:openID ] forKey:kOtherOpenID];
    [userDefaults synchronize];
}

+ (NSString *)lastOtherOpenID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kOtherOpenID];
    return [HSPublic controlNullString:result];
}

+ (NSString *)controlNullString:(NSString *)ori
{
    NSString *result = @"";
    if (ori.length > 0) {
        result = ori;
    }
    return result;
}

#pragma mark -
#pragma mark 帐号信息

+ (NSString *)lastOtherUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kOtherLoginUserName];
    result = [self controlNullString:result];
    return result;
}

+ (void)saveLastOtherUserName:(NSString *)userName
{
    NSString *result = [self controlNullString:userName];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:result forKey:kOtherLoginUserName];
    [userDefaults synchronize];
}

+ (NSString *)lastOtherHeaderImgURL
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kOtherLoginHeaderImgURL];
    result = [self controlNullString:result];
    return result;

}

+ (void)savelastOtherHeaderImgURL:(NSString *)imgURL
{
    NSString *result = [self controlNullString:imgURL];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:result forKey:kOtherLoginHeaderImgURL];
    [userDefaults synchronize];

}

static NSString *const kUserNameKey = @"lastUserNameKey";

static NSString *const kPasswordKey = @"lastPasswordKey";

/// 保存上次的用户名称
+ (void)saveLastUserName:(NSString *)userName
{
    NSString *result = [self controlNullString:userName];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:result forKey:kUserNameKey];
    [userDefaults synchronize];
}

/// 取出上次登录的用户名
+ (NSString *)lastUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kUserNameKey];
    result = [self controlNullString:result];
    return result;
}

/// 保存上次的密码
+ (void)saveLastPassword:(NSString *)password
{
    NSString *result = [self controlNullString:password];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:result forKey:kPasswordKey];
    [userDefaults synchronize];

}

/// 取出上次登录的密码
+ (NSString *)lastPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kPasswordKey];
    result = [self controlNullString:result];
    return result;

}

#pragma mark -
#pragma mark 帐号登录

+ (void)loginIn
{
    if (![HSPublic isLoginInStatus]) { /// 不在登录状态 
        return;
    }
    
    NSString *userName = [HSPublic lastUserName];
    NSString *passWord = [HSPublic lastPassword];
    NSString *openID = [HSPublic lastOtherOpenID];
    
    NSDictionary *parametersDic;
    NSString *loginURL = nil;
    if ([HSPublic loginType] == kAccountLoginType) { /// 帐号登录
        
        loginURL = kLoginURL;
        parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                          kPostJsonUserName:userName,
                          kPostJsonPassWord:passWord
                          };

    }
    else
    {
        loginURL = kOtherLoginURL;
        NSString *type = nil;
        
        if ([HSPublic loginType] == kQQLoginType) {
            type = kOtherLoginQQType;
        }
        else
        {
            type = kOtherLoginWeixinType;
        }
        parametersDic = @{kPostJsonOpenid:openID,
                          kPostJsonType:type};

    }
       // 142346261  123456
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager POST:loginURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            [self loginIn];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            HSUserInfoModel *userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:json error:nil];
            if (userInfoModel.id.length > 0) { /// 登录后返回有数据
                [HSPublic saveUserInfoToPlist:[userInfoModel toDictionary]];
            }
        }
        else
        {
            
        }
    }];

}

static const double kTimedLoginInterval = 60*60;

+ (void)timedLoginIn
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTimedLoginInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

+ (void)timerAction
{
    [HSPublic loginIn];
}

+ (void)showHudInWindowWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = NO;
    hud.alpha = 0.9;
    hud.labelText = text;
    hud.margin = 10.f;
    hud.yOffset = 150;
    hud.animationType = MBProgressHUDAnimationZoomOut;// | MBProgressHUDAnimationZoomIn;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];

}


+ (BOOL)isAreaInJiangZheHu:(NSString *)sheng
{
    if (sheng.length < 2) {
        return NO;
    }
    
    NSArray *desArr = @[@"浙江",@"江苏",@"上海"];
    __block BOOL isIn = NO;
    
    [desArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [sheng rangeOfString:obj];
        if (range.location != NSNotFound) {
            isIn = YES;
            *stop = YES;
        }
        
    }];
    
    return isIn;
}


/// 是否记住密码
+ (BOOL)isRemeberPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *result = [userDefaults objectForKey:kRemeberPassword];
    BOOL isRe = result == nil ? NO : [result boolValue];
    return isRe;
}

/// 设置记住密码
+ (void)setRemeberPassword:(BOOL)isRemeber
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:isRemeber] forKey:kRemeberPassword];
    [userDefaults synchronize];

}

/// 根据订单的状态status 返回 具体的描述
+ (NSString *)orderStatusStrWithState:(NSString *)status
{
    if (status.length == 0) {
        return @"";
    }
    
    NSString *result = @"";
    int sta = [status intValue];
    
    //1.代付款 2.待发货 3.待收获 4.完成 5。关闭
    switch (sta) {
        case 1:
        {
            result = @"待付款";
        }
            break;
        case 2:
        {
             result = @"待发货";
        }
            break;

        case 3:
        {
             result = @"待收货";
        }
            break;

        case 4:
        {
             result = @"完成";
        }
            break;

        case 5:
        {
             result = @"关闭";
        }
            break;

            
        default:
            break;
    }
    
    return result;
}

+ (NSString *)dateFormWithTimeDou:(double)timeDou
{
    NSString *rst = @"";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeDou];
    NSDateFormatter *formtter = [[NSDateFormatter alloc] init];
    [formtter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    rst = [formtter stringFromDate:date];
    
    return rst;
}

+ (NSString *)dateFormatterWithTimeIntervalSince1970:(double)interval formatter:(NSString *)form
{
    NSString *rst = @"";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formtter = [[NSDateFormatter alloc] init];
    [formtter setDateFormat:form];
    rst = [formtter stringFromDate:date];
    
    return rst;
}

+ (BOOL)aliPaySuccess:(NSDictionary *)dic
{
    BOOL isSuc = NO;
    
    NSString *status = dic[kAliPayResultStatus];
    if ([status isEqualToString:kAliPaySuccessResultStatus]) {
        isSuc = YES;
    }
    return isSuc;
}

@end
