//
//  HSMineAddressViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSUserInfoModel.h"
#import "HSAddressModel.h"

/// 地址的模式 1为选择地址  2为查看并可以编辑
typedef NS_ENUM(NSUInteger,  HSMineAddressControlType) {
   HSMineAddressSelecteType = 1,
   HSMineAddressReadType = 2
};

typedef void(^HSMineSelectAddressBlock)(HSAddressModel *addressModel);

@interface HSMineAddressViewController : HSBaseViewController

@property (strong, nonatomic) HSUserInfoModel *userInfoModel;
/// 地址的类型
@property (assign, nonatomic) HSMineAddressControlType addressType;
/// 地址的id  在type为 HSMineAddressSelecteType 传入
@property (copy, nonatomic) NSString *addressID;

@property (copy, nonatomic) HSMineSelectAddressBlock selectBlock;

@end
