//
//  HSSubmitOrderViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSUserInfoModel.h"

/// 提交订单
@interface HSSubmitOrderViewController : HSBaseViewController

/// 记住商品选择数量的字典 key 为商品的id
@property (strong, nonatomic) NSDictionary *itemNumDic;
/// 包含商品信息的数组 单个为commodityModel
@property (strong, nonatomic) NSArray *itemsDataArray;

@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

@end
