//
//  HSRegisterViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-30.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSRegisterViewControllerRegisterSuccessBlock)(NSString *userName, NSString *password);

/// 找回密码 和 注册 共有 页面
@interface HSRegisterViewController : HSBaseViewController

@property (assign, nonatomic) BOOL isRegister;

@property (copy, nonatomic) HSRegisterViewControllerRegisterSuccessBlock registerSuccessBlock;

@end
