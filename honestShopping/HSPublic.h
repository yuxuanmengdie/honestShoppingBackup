//
//  public.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, HSLoginType) {
    kAccountLoginType = 1,
    kWenxiLoginType,
    kQQLoginType,
    kSinaLoginType,
    kNoneLoginType
};
@interface HSPublic : NSObject


///color画图

+ (UIImage *) ImageWithColor: (UIColor *)color;

+ (UIImage *) ImageWithColor: (UIColor *) color frame:(CGRect)aFrame;

///修改图片尺寸
+ (UIImage*) drawInRectImage:(UIImage*)startImage size:(CGSize)imageSize;

//添加不要云备份属性。
+ (BOOL)addSkipBAckupAttributeItemAtURL:(NSURL *)URL;
/// doc 添加不要保存云备份
+ (BOOL)addSkipBackupAttributeDoc;

///判断是否为邮箱格式
+ (BOOL)isEmaliRegex:(NSString *)email;

//判断是否为手机号码
+ (BOOL)isPhoneNumberRegex:(NSString *)phone;

///返回 md5
+ (NSString *)md5Str:(NSString *)oriStr;

/// 获取ip4地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

/// 获取如ip4，ip6，wifi
+ (NSDictionary *)getIPAddresses;

/// 字典转str
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

/// 保存用户信息到plist文件中
+ (void)saveUserInfoToPlist:(NSDictionary *)userDic;

/// 取出用户信息
+ (NSDictionary *)userInfoFromPlist;

/// 是否登录状态
+ (BOOL)isLoginInStatus;

/// 设置登录状态 以及登录的方式
+ (void)setLoginInStatus:(BOOL)isLogin type:(HSLoginType)type;

/// 登出
+ (void)setLoginOut;

/// 返回登录的方式
+ (HSLoginType)loginType;

#pragma mark - 
#pragma mark 第三方登录
/// 保存openID
+ (void)saveOtherOpenID:(NSString *)openID;

/// 取出openID
+ (NSString *)lastOtherOpenID;

/// 取出第三方的username
+ (NSString *)lastOtherUserName;

/// 保存第三方的username
+ (void)saveLastOtherUserName:(NSString *)userName;

/// 第三方的头像地址
+ (NSString *)lastOtherHeaderImgURL;

/// 保存第三方头像地址
+ (void)savelastOtherHeaderImgURL:(NSString *)imgURL;

/// 保存上次的用户名称
+ (void)saveLastUserName:(NSString *)userName;

/// 取出上次登录的用户名
+ (NSString *)lastUserName;

/// 保存上次的密码
+ (void)saveLastPassword:(NSString *)password;

/// 取出上次登录的密码
+ (NSString *)lastPassword;

/// 处理字符串 为nil 时返回""
+ (NSString *)controlNullString:(NSString *)ori;

/// 登录 防止sessioncode 过期
+ (void)loginIn;

/// 定时登录 默认间隔1小时
+ (void)timedLoginIn;

/// showHud
+ (void)showHudInWindowWithText:(NSString *)text;

/// 是否是江浙沪
+ (BOOL)isAreaInJiangZheHu:(NSString *)sheng;

/// 是否记住密码
+ (BOOL)isRemeberPassword;

/// 设置记住密码
+ (void)setRemeberPassword:(BOOL)isRemeber;

/// 根据订单的状态status 返回 具体的描述
+ (NSString *)orderStatusStrWithState:(NSString *)status;

///根据从1970年的double 数字 转换成时间2015-01-01 00：00：00
+ (NSString *)dateFormWithTimeDou:(double)timeDou;

///根据从1970年的double 数字 转换成form定义的时间 例如 @"YYYY-MM-DD HH:mm:ss"
+ (NSString *)dateFormatterWithTimeIntervalSince1970:(double)interval formatter:(NSString *)form;

/// 判断支付宝支付结果
+ (BOOL)aliPaySuccess:(NSDictionary *)dic;
@end
