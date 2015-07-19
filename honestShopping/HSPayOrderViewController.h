//
//  HSPayOrderViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSAddressModel.h"
#import "HSUserInfoModel.h"


@interface HSPayOrderViewController : HSBaseViewController

/// 记住商品选择数量的字典 key 为商品的id
//@property (strong, nonatomic) NSDictionary *itemNumDic;

/// 包含商品信息的数组 单个为commodityModel
//@property (strong, nonatomic) NSArray *commdityDataArray;

/// 地址信息
//@property (strong, nonatomic) HSAddressModel *addressModel;

/// 个人信息
@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

///
@property (copy, nonatomic) NSString *orderID;


@end
