//
//  HSPayOrderViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSPayOrderViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#import "UIView+HSLayout.h"
#import "HSSettleView.h"
#import "HSSubmitOrderAddressTableViewCell.h"
#import "HSSubmitOrderCommdityTableViewCell.h"
#import "HSPayTypeTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HSOrderStatusTableViewCell.h"

#import "HSCommodityItemDetailPicModel.h"
#import "HSOrderModel.h"
#import "payRequsestHandler.h"
#import "WXApi.h"

@interface HSPayOrderViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    
    NSArray *_commdityDataArray;
    
     HSSubmitOrderAddressTableViewCell *_placeAddressCell;
    
    /// 支付方式 0 支付宝 1微信
    int _payType;
    
    /// 订单信息
    HSOrderModel *_orderModel;
    
    /// 一分钱测试的提示
    BOOL _payTestFlag;
    
    /// 更新订单的尝试次数
    int _orderUpdateCount;
}

@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;

@property (weak, nonatomic) IBOutlet HSSettleView *settleView;

@end

@implementation HSPayOrderViewController

/// 更新订单最大尝试次数
static const int kUpdateOrderMaxCount = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _payTestFlag = NO;
    
    _orderUpdateCount = 0;
    _payType = 0;
    
//    [self setNavBarRightBarWithTitle:@"1分钱测试" action:@selector(payTest)];
    [_orderDetailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderAddressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class])];
    [_orderDetailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class])];
    [_orderDetailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSPayTypeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSPayTypeTableViewCell class])];
    [_orderDetailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSOrderStatusTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSOrderStatusTableViewCell class])];

    [_orderDetailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    _orderDetailTableView.dataSource = self;
    _orderDetailTableView.delegate = self;

//    [self setupSettleView];
    [self getOrderDetailRequest:[HSPublic controlNullString:_userInfoModel.id] orderID:[HSPublic controlNullString:_orderID] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    
    _settleView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_paySuccess:) name:kHSPaySuccess object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_payFailed:) name:kHSPayFailed object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
#pragma mark 一分钱测试
- (void)payTest
{
    if (!_payTestFlag) {
        _payTestFlag = YES;
        [self alert:@"提示" msg:@"切换下面列表中的\"支付方式\"，可以选择支付宝或者微信的1分钱测试"];
        return;
    }
    
    HSOrderModel *model = [_orderModel copy];
    model.order_sumPrice = @"0.01";
    if (_payType == 0) {
        [self aliPayWithOrderModel:model title:[HSPublic controlNullString:[self productName:model]] desc:[HSPublic controlNullString:[self productName:model]]];
    }else
    {
        [self weixinPay:model];
    }

//     [[NSNotificationCenter defaultCenter] postNotificationName:kHSPaySuccess object:nil userInfo:nil];
}

#pragma mark -
#pragma mark settleView 的设置
- (void)setupSettleView
{
    [_settleView.settltButton setTitle:@"支付订单" forState:UIControlStateNormal];
    _settleView.textLabel.text = [NSString stringWithFormat:@"%0.2f元",[self totolMoney]];
    if (![_orderModel.status isEqualToString:@"1"]) { /// 不是待支付
        _settleView.settltButton.enabled = NO;
    }
    
    __weak typeof(self) wself = self;
    
    _settleView.settleBlock = ^{
       // [wself aliPay];
        __strong typeof(wself) swself = wself;
        if (swself->_payType == 0) {
            [swself aliPayWithOrderModel:swself->_orderModel title:[HSPublic controlNullString:[swself productName:swself->_orderModel]] desc:[HSPublic controlNullString:[swself productName:swself->_orderModel]]];
        }else
        {
            [swself weixinPay:swself->_orderModel];
        }
    };
}

#pragma mark -
#pragma mark 获取订单详情
- (void)getOrderDetailRequest:(NSString *)uid orderID:(NSString *)orderID sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonOrderId:orderID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetOrderDetailURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenMsg];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenMsg];
        if (operation.responseData == nil) {
            [self showReqeustFailedMsg];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }

        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            HSOrderModel *orderModel = [[HSOrderModel alloc] initWithDictionary:tmpDic error:nil];
            if (orderModel.id.length > 0) {
                _orderModel = orderModel;
                _commdityDataArray = _orderModel.item_list;
                _settleView.hidden = NO;
                [self setupSettleView];
                
                [_orderDetailTableView reloadData];
            }
        }
        else
        {
            
        }
    }];

}
#pragma mark -
#pragma mark 重新请求
- (void)reloadRequestData
{
    [self getOrderDetailRequest:[HSPublic controlNullString:_userInfoModel.id] orderID:[HSPublic controlNullString:_orderID] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];

}


#pragma mark -
#pragma mark 获取商品的总数
- (int)totalNum
{
    __block int num = 0;
    
    [_commdityDataArray enumerateObjectsUsingBlock:^(HSOrderitemModel *obj, NSUInteger idx, BOOL *stop) {
        int count = [obj.quantity intValue];
        num += count;
    }];
    
    return num;
}

#pragma mark -
#pragma mark 获取总价格
- (float)totolMoney
{
    float result = [_orderModel.order_sumPrice floatValue];
    
    return result;
//    __block float total = 0.0;
//    [_commdityDataArray enumerateObjectsUsingBlock:^(HSCommodityItemDetailPicModel *obj, NSUInteger idx, BOOL *stop) {
//        
//        NSString *cid = [HSPublic controlNullString:obj.id];
//        NSNumber *num = _itemNumDic[cid];
//        int count = [num intValue] < 0 ? 0 : [num intValue];
//        float price = [obj.price floatValue] < 0 ? 0: [obj.price floatValue];
//        
//        total += count * price;
//        
//    }];
//    return total;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark 支付宝支付

- (void)aliPayWithOrderModel:(HSOrderModel *)orderModel title:(NSString *)title desc:(NSString *)desc
{
    /*
     *点击获取prodcut实例并初始化订单信息
     */
//    Product *product = [self.productList objectAtIndex:indexPath.row];
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088511141292044";
    NSString *seller = @"jsds@news.cn";//@"alipayrisk10@alipay.com";
    NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANWYfwyTiW2gNjijRHXywp+QdtvafdR8G/YuP1mg7SmIz0N/DijyVLF3xK86L3TSLG/DOYlI/cq4tzUQvZJQW9hSjSJ9AIdvVbLuVOtwWihdmRIEfF7PVf3yLy6wGghZ6qPaFAADgQ2YQErlmm+jepVW/LeK3diI80Wq1ln0hKtlAgMBAAECgYEA0h4/7Uk9yh/u9ux1rmnvVzSwGDrpyZuFjjmUjEEozNEOw2E7tsAc3K/rRk1A3fTbTd6IvSqWr1PitksPkd2HWotGygrcJgT+Ld3mGXA4gxlJZyZOmBDNpxlgq4hxbY/+txakdykWIfeJOduDowGOjUmzZV3tChKcCxDT4uEus8ECQQD6WJ3EqDX/n4HTfJXNbAwxFPdr2hVKhp281ZYh5CT3MG1pD3wrkxLF4klOKxH2KTkBE6uvS31u67C/no4esaDNAkEA2mtn9OxhF8PG0ClhyTOF5PGR/BCUaUT6ALq2Cd3WvKJP1WTvitew9R+KFQzxUOb6gk014TuFhQLx761p5OxU+QJBAMUIEcPBkB5L7+X/W/d9XmsS0Vi1H6S0JlmE0NCDuwRBvRq+8T9qVZAg9QjspQpUj2Tlkm44v9QY89ccd0Z5DtECQDY9pARTy0zOhondLPZ9QAv53an+KAz4XyldNKXAnHodyLuSpFYTeFN3MKBHpYnUwnMnX3D+igrdD13Y78o00mkCQQC9ivcRNA/ORQ9WuWkJZM8HzylHl8Tek1n3YLQ4ZirhlDtyIW+DiMKhQttZ5bCf0eV71YQbnJ1TrviBmUqZicZo";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = _orderModel.orderId;//[self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName = title;//product.subject; //商品标题
    order.productDescription = desc;//product.body; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",[orderModel.order_sumPrice floatValue]]; //商品价格 @"0.01";//
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"hsalisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"%s reslut = %@", __func__,resultDic);
            NSDictionary *memo = resultDic;
            
            if ([HSPublic aliPaySuccess:memo]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kHSPaySuccess object:nil userInfo:nil];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kHSPayFailed object:nil userInfo:@{kHSPayResultMsg:[HSPublic controlNullString:memo[kAliPayMemo]]}];
            }

        }];
        
    }

}

#pragma mark -
#pragma mark 微信支付
- (void)weixinPay:(HSOrderModel *)model
{
    //本实例只是演示签名过程， 请将该过程在商户服务器上实现
    
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc] ;
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict =  [self wenxinPayInfo:req model:model];//[req sendPay_demo];
    
    if(dict == nil){
        //错误提示
        //NSString *debug = [req getDebugifo];
        
        //[self alert:@"提示信息" msg:debug];
        [self alert:@"" msg:@"签名失败，请重试"];
        
        //NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }

}

#pragma mark -
#pragma mark 返回微信参数
- (NSMutableDictionary *)wenxinPayInfo:(payRequsestHandler *)payRequsestHandler model:(HSOrderModel *)model
{
    
    //订单标题，展示给用户
    NSString *order_name    =  [self productName:model];//@"V3支付测试";
    //订单金额,单位（分）
    NSString *order_price   =  [NSString stringWithFormat:@"%.f",[model.order_sumPrice floatValue]*100];//@"1";//1分钱测试
    
    
    //================================
    //预付单参数订单设置
    //================================
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSString *orderno   =  model.orderId;//[NSString stringWithFormat:@"%ld",time(0)];
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject: APP_ID             forKey:@"appid"];       //开放平台appid
    [packageParams setObject: MCH_ID             forKey:@"mch_id"];      //商户号
    [packageParams setObject: @"APP-001"        forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr          forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"APP"            forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: order_name        forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: NOTIFY_URL        forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: orderno           forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: @"196.168.1.1"    forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: order_price       forKey:@"total_fee"];       //订单金额，单位为分
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid;
    prePayid            = [payRequsestHandler sendPrepay:packageParams];
    
    if ( prePayid != nil) {
        //获取到prepayid后进行第二次签名
        
        NSString    *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [WXUtil md5:time_stamp];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        //package       = [NSString stringWithFormat:@"Sign=%@",package];
        package         = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: APP_ID        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: package      forKey:@"package"];
        [signParams setObject: MCH_ID        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: prePayid     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [payRequsestHandler createMd5Sign:signParams];
        
        //添加签名
        [signParams setObject: sign         forKey:@"sign"];
        
        //返回参数列表
        return signParams;
        
    }else{

    }
    return nil;

}

#pragma mark - 
#pragma mark 获取商品标题
- (NSString *)productName:(HSOrderModel *)orderModel
{
   __block NSString *result = @"商品";
    
    [orderModel.item_list enumerateObjectsUsingBlock:^(HSOrderitemModel *obj, NSUInteger idx, BOOL *stop) {
        if ([result isEqualToString:@"商品"]) {
            result = obj.title;
        }
        else
        {
            result = [NSString stringWithFormat:@"%@\n%@",result,[HSPublic controlNullString:obj.title ]];
        }
        
    }];
    
    return result;

}

#pragma mark -
#pragma mark 更新订单状态
- (void)updateOrderStatus:(NSString *)orderID uid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    _orderUpdateCount++;
    [self showhudLoadingInWindowWithText:@"订单完成中..." isDimBackground:NO];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonOrderId:orderID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kUpdateOrderNextURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            if (_orderUpdateCount <= kUpdateOrderMaxCount) {
                [self updateOrderStatus:orderID uid:uid sessionCode:sessionCode];
            }
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }

        
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            NSNumber *status = tmpDic[kPostJsonStatus];
            if (status != nil && [status boolValue]) { /// 订单更新成功
                [self showHudInWindowWithText:@"支付成功，订单已完成!"];
                [self popToRootNav];
            }
            }
        else
        {
            
        }
    }];

}


#pragma mark -
#pragma mark 获取商品描述

#pragma mark -
#pragma mark tableview dataSource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (section == 0) { // 地址 + 订单状态
        num = 2;
    }
    else // 商品种类  + 运费 + 总计 + 付款方式 + 配送方式
    {
        num = _commdityDataArray.count + 4;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { /// section 0
        
        if (indexPath.row == 0) {
            HSOrderStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSOrderStatusTableViewCell class]) forIndexPath:indexPath];
            cell.orderStatusLabel.text = [NSString stringWithFormat:@"订单状态：%@",[HSPublic orderStatusStrWithState:_orderModel.status]];
            cell.orderIDLabel.text = [NSString stringWithFormat:@"订单编号：%@",[HSPublic controlNullString:_orderModel.orderId]];
            cell.orderTimeLabel.text = [NSString stringWithFormat:@"订单时间：%@",[HSPublic controlNullString:[HSPublic dateFormWithTimeDou:[_orderModel.add_time doubleValue]]]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
        else
        {
            HSSubmitOrderAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class]) forIndexPath:indexPath];
            [cell setupWithUserName:_orderModel.userName phone:_orderModel.mobile address:_orderModel.address];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }
    }
    else
    {
        if (indexPath.row < _commdityDataArray.count) { /// 商品详情
            HSSubmitOrderCommdityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) forIndexPath:indexPath];
            HSOrderitemModel *itemlModel = _commdityDataArray[indexPath.row];
            [cell setupWithOrderItemModel:itemlModel];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            if (indexPath.row == _commdityDataArray.count) // 运费
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

                UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:501];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:502];
                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 501;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeLeading secondView:leftLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 502;
                    rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];
                    
                }
                leftLabel.text = @"运费：";
                rightLabel.text = [NSString stringWithFormat:@"%@元",_orderModel.freeprice];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else  if (indexPath.row == _commdityDataArray.count + 1)// 合计
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];

                UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:501];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:502];
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 502;
                    //rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];
                    
                }
                
                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 501;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:leftLabel fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                int num = [self totalNum]; // 商品总数
                float price = [self totolMoney];
                NSString *str1 = @"共有";
                NSString *str2 = @"件商品";
                NSString *str3 = @"合计:";
                NSString *leftStr = [NSString stringWithFormat:@"%@%d%@",str1,num,str2];
                NSString *rightStr = [NSString stringWithFormat:@"%@￥%0.2f",str3,price];
                
                NSMutableAttributedString *left = [[NSMutableAttributedString alloc] initWithString:leftStr];
                NSMutableAttributedString *right = [[NSMutableAttributedString alloc] initWithString:rightStr];
                
                [left addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, str1.length)];
                [left addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:NSMakeRange(str1.length, leftStr.length-str2.length-str1.length)];
                [left addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(leftStr.length-str2.length,str2.length)];
                
                [right addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0,str3.length)];
                [right addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(str3.length,right.length-str3.length)];
                leftLabel.attributedText = left;
                rightLabel.attributedText = right;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else  if (indexPath.row == _commdityDataArray.count + 2)// 付款方式
            {
                HSPayTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSPayTypeTableViewCell class]) forIndexPath:indexPath];
                cell.leftLabel.text = @"支付方式：";
                if (_payType == 0) {
                    cell.aliPayButton.selected = YES;
                    cell.weixinPayButton.selected = NO;
                }
                else
                {
                    cell.aliPayButton.selected = NO;
                    cell.weixinPayButton.selected = YES;
                }
                __weak typeof(self) wself = self;
                cell.payTypeBlock = ^(int type){ // 0 支付宝 1微信
                    __strong typeof(wself) swself = wself;
                    swself->_payType = type;
                    
                };
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else /// 配送方式
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
                
                UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:501];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:502];
                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 501;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeLeading secondView:leftLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 502;
                    rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_dispacingWithFisrtView:leftLabel fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];
                    
                }
                leftLabel.text = @"配送方式：";
                rightLabel.text = @"一周之内可以收货";
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;

            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            height = 76;
        }
        else
        {
            if (_placeAddressCell == nil) {
                _placeAddressCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class])];
                _placeAddressCell.bounds = tableView.bounds;
                [_placeAddressCell setNeedsLayout];
            }
            [_placeAddressCell setupWithUserName:_orderModel.userName phone:_orderModel.mobile address:_orderModel.address];
            _placeAddressCell.detailLabel.preferredMaxLayoutWidth = _placeAddressCell.detailLabel.frame.size.width;
            [_placeAddressCell.contentView updateConstraintsIfNeeded];
            [_placeAddressCell.contentView layoutIfNeeded];
            height = [_placeAddressCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0;

        }
        
    }
    else
    {
        if (indexPath.row < _commdityDataArray.count) {
            height = 80;
        }
        else
        {
            height = 44;
        }
    }
    
    return height;
}


//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    
    [alter show];
}
#pragma mark -
#pragma mark 支付结果
- (void)p_paySuccess:(NSNotification *)noti
{
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self updateOrderStatus:[HSPublic controlNullString:_orderID] uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    //[self alert:@"" msg:@"支付成功!"];
    //[self popToRootNav];
   //
}

- (void)p_payFailed:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    [self alert:@"支付失败!" msg:[HSPublic controlNullString:userInfo[kHSPayResultMsg]]];
}

#pragma mark -
#pragma mark delloc
- (void)dealloc
{
    [self.httpRequestOperationManager.operationQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}

@end
