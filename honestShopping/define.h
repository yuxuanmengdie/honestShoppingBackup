//
//  define.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#ifndef honestShopping_define_h
#define honestShopping_define_h

#pragma mark -
#pragma mark json 中key的宏定义
///JsonArray
static NSString *const kJsonArray = @"JsonArray";

/// json 中key的宏定义
static NSString *const kPostJsonKey = @"key";

static NSString *const kPostJsonUserName = @"username";

static NSString *const kPostJsonPassWord = @"password";

static NSString *const kPostJsonUid = @"uid";

static NSString *const kPostJsonSessionCode = @"sessionCode";

static NSString *const kPostJsonid = @"id";

static NSString *const kPostJsonPhone = @"phone";

static NSString *const kPostJsonEmail = @"email";

static NSString *const kPostJsonConsignee = @"consignee";

static NSString *const kPostJsonGender = @"gender";

static NSString *const kPostJsonIntro = @"intro";

static NSString *const kPostJsonByear = @"byear";

static NSString *const kPostJsonBmonth = @"bmonth";

static NSString *const kPostJsonBday = @"bday";

static NSString *const kPostJsonProvince = @"province";

static NSString *const kPostJsonAddress = @"address";

static NSString *const kPostJsonAddId = @"add_id";

static NSString *const kPostJsonMobile = @"mobile";

static NSString *const kPostJsonSheng = @"sheng";

static NSString *const kPostJsonShi = @"shi";

static NSString *const kPostJsonQu = @"qu";

static NSString *const kPostJsonOldPassword = @"oldPassword";

static NSString *const kPostJsonNewPassword = @"newPassword";

static NSString *const kPostJsonItemid =  @"itemId";

static NSString *const kPostJsonStatus = @"status";

static NSString *const kPostJsonCid = @"cid";

static NSString *const kPostJsonPage = @"page";

static NSString *const kPostJsonSize = @"size";

static NSString *const kPostJsonCode = @"code";

static NSString *const kPostJsonError = @"error";

static NSString *const kPostJsonKeyWord = @"keyWord";

static NSString *const kPostJsonType = @"type";

static NSString *const kPostJsonCouponId = @"couponId";

static NSString *const kPostJsonAddressName = @"addressName";

static NSString *const kPostJsonSupportmethod = @"supportmethod";

static NSString *const kPostJsonFreetype = @"freetype";

static NSString *const kPostJsonList = @"list";

static NSString *const kPostJsonQuantity = @"quantity";

static NSString *const kPostJsonOrderNo = @"orderNo";

static NSString *const kPostJsonOpenid = @"openid";

static NSString *const kPostJsonOrderId = @"orderId";

static NSString *const kPostJsonCouponNo = @"couponNo";

static NSString *const kPostJsonFreeprice = @"freeprice";

static NSString *const kPostJsonNum = @"num";

#pragma mark -
#pragma mark 请求url
/// 注册
#define kRegisterURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=register"]
/// 登录
#define kLoginURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=login"]
/// 第三方登陆接口(统一接口) weixin or qq
#define kOtherLoginURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=otherLogin"]
/// 第三方登录 /index.php?g=api&m=User&a=weixinLogin 微信
#define kWeixinLoginURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=weixinLogin"]
/// QQ 登录
#define kQqnLoginURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=qqnLogin"]
///获取手机验证码
#define kGetVerifyCodeURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getVerifyCode"]
/// 验证手机验证码
#define kVerifyCodeURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=verifyCode"]
/// 密码设置 找回
#define kSetPasswordURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=setPassword"]
/// 用户信息
#define kGetUserInfoURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getUserInfo"]
/// 个人信息更新
#define kUserInfoUpdateURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=userInfoUpdate"]
/// 签到
#define kSignURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=sign"]
/// 修改密码
#define kChangePassWordURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&mUser&a=changePassWord"]
/// 判断是否是会员
#define kIsVIPURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=isVIP"]


/// 收货地址
#define kGetAddressURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getAddress"]
/// 收货地址更新  （新增收货地址不传id)
#define kAddressUpdateURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=addressUpdate"]
/// 获取默认收货地址
#define kGetDefaultAddressURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getDefaultAddress"]
/// 设置默认收货地址
#define kSetDefaultAddressURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=setDefaultAddress"]
/// 删除收货地址
#define kDelAddressURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=delAddress"]

/// 分类列表
#define kGetCateURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getCate"]
/// 三品一标下面分类 获取三品一标(1.有机产品2.绿色产品3.无公害产品4.地理标志)
#define kGetSpybByTypeURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getSpybByType"]
/// 搜索列表
#define kGetSearchListURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getSearchList"]
/// 商品信息
#define kGetItemByIdURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getItemById"]
/// 列表下的商品信息
#define kGetItemsByCateURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getItemsByCate"]
/// 列表下的广告商品信息
#define kGetAdsByCateURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getAdsByCate"]
/// 获取首页商品
#define kGetIndexItemURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getIndexItem"]


/// 获取收藏商品列表
#define kGetFavoriteURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getFavorite"]
/// 收藏
#define kAddFavoriteURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=addFavorite"]
/// 删除收藏
#define kDelFavoriteURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=delFavorite"]
/// 发现
#define kGetDiscoverURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getDiscover"]
/// 获取banner
#define kGetBannerURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getBanner"]


/// 获取用户订单列表(传status值则会根据status筛选) 1.代付款 2.待发货 3.待收获 4.完成 5。关闭
#define kGetOrderListURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=getOrderList"]
/// 获取订单详情
#define kGetOrderDetailURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=getOrderDetail"]
/// 生成订单（调取下个订单状态）
#define kAddOrderURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=addOrder"]
/// 修改订单状态
#define kUpdateOrderNextURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=updateOrderNext"]
/// 获取运费 freetype 0包邮1非包邮
#define kGetFreePriceURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=getFreePrice"]

/// 获取首页优惠劵列表
#define kGetCouponListURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getCouponList"]
/// 获取用户优惠劵
#define kGetCouponsByUidURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getCouponsByUid"]
/// 用户优惠劵
#define kGetCouponsByUidURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=getCouponsByUid"]
/// 领取优惠劵
#define kBlindCouponWithUserURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=User&a=blindCouponWithUser"]
/// 获取优惠劵ID by 优惠劵号 /index.php?g=api&m=Order&a=getCouponIdByCouponNo
#define kGetCouponIdByCouponNoURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=getCouponIdByCouponNo"]

/// 获取微信支付perpayid
#define kGetWxPerpayidURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Order&a=getWxPerpayid"]
/// 分享
#define kShareURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=share"]
///获取引导图（advert目录）
#define kGetGuideURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getGuide"]
/// 获取欢迎图（advert目录）
#define kGetWelcomeURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/index.php?g=api&m=Item&a=getWelcome"]


#pragma mark -
#pragma mark 图片前缀
/// banner 图片前缀路径
#define kBannerImageHeaderURL  [NSString stringWithFormat:@"%@%@",kURLHeader,@"/data/upload/advert/"]
/// 普通图片路径
#define kImageHeaderURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/data/upload/item/"]//@"http://203.192.7.23/data/upload/item/"
/// 优惠券 前缀路径
#define kCoupImageHeaderURL [NSString stringWithFormat:@"%@%@",kURLHeader,@"/data/upload/coup/"]


#pragma mark -
#pragma mark userdefault中保存用户是否登录 的key
static NSString *const kUserIsLoginKey = @"HS_kUserIsLoginKey";
/// 保存到用户信息保存到doc 的plist文件
static NSString *const kUserInfoPlistName = @"HSuser";
/// 登录的方式
static NSString *const kLoginType = @"hs_loginType";
/// 第三方的openID
static NSString *const kOtherOpenID = @"hs_otherOpenID";
/// 记住密码的key
static NSString *const kRemeberPassword = @"hs_remeberPassword";

#pragma mark -
#pragma mark 占位图片

#define kPlaceholderImage  [UIImage imageNamed:@"bank_icon_failed"]

#define kAppYellowColor ColorRGB(253, 169, 10)


#pragma mark -
#pragma mark 各平台的key
static NSString *const kUMengAppKey = @"53290df956240b6b4a0084b3";//@"556e697267e58ee877007380"; /放心吃
/// 友盟推送
static NSString *const kUMengPushMessageAppKey = @"556e697267e58ee877007380";

//qq APP ID:1104470651  APP KEY:1VATaXjYJuiJ0itg   URL schema QQ41D4E27B


#pragma mark -
#pragma mark 支付宝key

static NSString *const kAliPayMemo = @"memo";

static NSString *const kAliPayResultStatus = @"resultStatus";
/// 支付成功的status
static NSString *const kAliPaySuccessResultStatus = @"9000";

#pragma mark - 
#pragma mark  支付成功， 支付失败的通知key

static NSString *const kHSPaySuccess = @"kHSPaySuccess1111";

static NSString *const kHSPayFailed = @"kHSPayFailed111";

static NSString *const kHSPayResultMsg = @"kHSPayResultMsg";

#pragma mark -
#pragma mark  第三方登录的type 字段
static NSString *const kOtherLoginQQType = @"qq";

static NSString *const kOtherLoginWeixinType = @"weixin";

#pragma mark -
#pragma mark 第三方的username 头像地址等。

static NSString *const kOtherLoginUserName = @"OtherLoginUserName";

static NSString *const kOtherLoginHeaderImgURL = @"OtherLoginHeaderImgURL";


#endif

