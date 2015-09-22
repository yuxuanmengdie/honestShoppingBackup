//
//  HSSubmitCommentViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSUserInfoModel.h"

@class HSOrderModel;

@interface HSSubmitCommentViewController : HSBaseViewController

/// 个人信息
@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

///
@property (copy, nonatomic) NSString *orderID;

// 当 dataArray orderModel 均为nil 时 会发送请求
@property (strong, nonatomic) NSArray *dataArray;

@property (strong, nonatomic) HSOrderModel *orderModel;

@end
