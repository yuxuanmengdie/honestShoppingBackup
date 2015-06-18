//
//  HSEditAddressViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSAddressModel.h"
#import "HSUserInfoModel.h"

typedef NS_ENUM(NSUInteger,  HSEditAddressType) {
    HSeditaddressByAddType = 1,
    HSeditaddressByUpdateType = 2
};

typedef void(^HSEditAddressUpdateSuccessBlock)(HSAddressModel *addModel);

@interface HSEditAddressViewController : HSBaseViewController

@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

@property (strong, nonatomic) HSAddressModel *addressModel;
/// 修改类型
@property (assign, nonatomic) HSEditAddressType addressChangeType;

/// 更新地址信息成功后回调
@property (copy, nonatomic) HSEditAddressUpdateSuccessBlock updateBlcok;

@end
