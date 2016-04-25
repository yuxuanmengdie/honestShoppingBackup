//
//  HSPayMannager.m
//  honestShopping
//
//  Created by 张国俗 on 15-12-7.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSPayMannager.h"
#import "HSUserInfoModel.h"

@interface HSPayMannager ()
{
    AFHTTPRequestOperationManager *_requestOperationManager;
    
    id _observer;

}
@end

@implementation HSPayMannager

static NSString *const kPayRecord = @"payRecord";

+ (instancetype)sharePayMannager
{
    static HSPayMannager *shareMannager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareMannager = [[HSPayMannager alloc] init];
    });
    
    return shareMannager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_observer]; //移除通知
    [_requestOperationManager.operationQueue cancelAllOperations];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        __weak typeof(self) weakSelf = self;
        _observer = [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotiKey object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf startUpdatePayRecord];
        }];
    }
    
    return self;
}

- (void)startMonitoring
{
    if ([AFNetworkReachabilityManager sharedManager].isReachable) { //联网情况下
        [self startUpdatePayRecord];
    }
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: // 没有网络
            {
                [_requestOperationManager.operationQueue cancelAllOperations]; // 无网络时 取消请求
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                [self startUpdatePayRecord];
            }
                break;
                
            default:
                break;
        }
        
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

#pragma mark - 添加记录
- (void)addRecordWithUid:(NSString *)uid payType:(NSString *)type orderID:(NSString *)orderID sessionCode:(NSString *)sessionCode
{
    if (uid.length == 0 || type.length == 0 || orderID.length == 0 || sessionCode.length) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *record = [userDefaults objectForKey:kPayRecord];
    NSMutableArray *tmp = nil;
    
    if (record == nil || record.count == 0) {
        tmp = [[NSMutableArray alloc] init];
    }else {
        tmp = [[NSMutableArray alloc] initWithArray:record];
    }
    
    NSDictionary *info = @{kPostJsonUid:uid,
                           kPostJsonFreetype:type,
                           kPostJsonOrderId:orderID,
                           kPostJsonSessionCode:sessionCode};
    [tmp addObject:info];
    
    record = [NSArray arrayWithArray:tmp];
    [userDefaults setObject:record forKey:kPayRecord];
    [userDefaults synchronize];
}

#pragma mark - 移除记录
- (void)removeRecord:(NSString *)orderID
{
    if (orderID == nil) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *record = [userDefaults objectForKey:kPayRecord];
    
    if (record == nil || record.count == 0) {
        return;
    }

    NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:record];
    
    [record enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *ordID = obj[kPostJsonOrderId];
        if ([ordID isEqualToString:orderID]) {
            [tmp removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    
    record = [NSArray arrayWithArray:tmp];
    
    if (record.count > 0) {
        [userDefaults setObject:record forKey:kPayRecord];
    }else {
        [userDefaults removeObjectForKey:kPayRecord];
    }
    [userDefaults synchronize];
}

#pragma mark - 发送缓存的付款成功没有更新状态的订单
- (void)startUpdatePayRecord
{
    if (![HSPublic isLoginInStatus] || [HSPublic userInfoFromPlist] == nil){ // 不在登录状态 或者保存用户信息的plist 不存在时
        return;
    }
    
    HSUserInfoModel *infoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *record = [userDefaults objectForKey:kPayRecord];
    
    if (record == nil || record.count == 0) {
        return;
    }
    
    [record enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *orderID = obj[kPostJsonOrderId];
        NSString *uid = obj[kPostJsonUid];
        NSString *sessionCode = obj[kPostJsonSessionCode];
        if ([infoModel.id isEqualToString:uid]) { // uid 与登录帐号相同
            // 因为uid 就是当前用户时， userInfo 的sessionCode 是最新的
            sessionCode = [HSPublic controlNullString:infoModel.sessionCode];
        }
        [self updateOrderStateRequest:orderID uid:uid sessionCode:sessionCode];
    }];
    
}

- (void)updateOrderStateRequest:(NSString *)orderID uid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonOrderId:orderID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    
    [_requestOperationManager POST:kUpdateOrderNextURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) { // 没有收到结果，就一直轮询
            
            [self updateOrderStateRequest:orderID uid:uid sessionCode:sessionCode];
            
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSDictionary *jsonDic = (NSDictionary *)json;
            NSString *code = jsonDic[kPostJsonCode];
            
            if (![code isEqualToString:@"10001"]) { // 不是sessioncode 过期
                 [self removeRecord:orderID]; //移除记录
            }
            return;
            
        }
        
        if (jsonError == nil) {
            [self removeRecord:orderID];
        }
    }];
}

#pragma mark - 订单是否已存在
- (BOOL)isOrderRecordExist:(NSString *)orderID record:(NSArray *)recordArr
{
    if (orderID == nil || recordArr.count == 0 || recordArr == nil) {
        return NO;
    }
    
    __block BOOL isExist = NO;
    
    [recordArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *ordID = obj[kPostJsonOrderId];
        if ([ordID isEqualToString:orderID]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    
    return isExist;
    
}


@end
