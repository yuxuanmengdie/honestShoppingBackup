//
//  HSAddressDetailViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSAddressModel.h"
#import "HSUserInfoModel.h"

@interface HSAddressDetailViewController : HSBaseViewController

@property (strong, nonatomic) HSAddressModel *addressModel;

@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

@end
