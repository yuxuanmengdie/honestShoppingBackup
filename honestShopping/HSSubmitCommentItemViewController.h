//
//  HSSubmitCommentItemViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSUserInfoModel.h"

@interface HSSubmitCommentItemViewController : HSBaseViewController

/// 个人信息
@property (strong, nonatomic) HSUserInfoModel *userInfoModel;

///
@property (copy, nonatomic) NSString *orderID;

@end
