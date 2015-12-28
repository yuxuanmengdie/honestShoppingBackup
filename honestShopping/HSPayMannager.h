//
//  HSPayMannager.h
//  honestShopping
//
//  Created by 张国俗 on 15-12-7.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSPayMannager : NSObject

+ (instancetype)sharePayMannager;

// 启动网络监听
- (void)startMonitoring;

- (void)addRecordWithUid:(NSString *)uid payType:(NSString *)type orderID:(NSString *)orderID sessionCode:(NSString *)sessionCode;

@end
