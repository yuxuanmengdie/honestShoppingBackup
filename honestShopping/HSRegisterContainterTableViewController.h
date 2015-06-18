//
//  HSRegisterContainterTableViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSRegisterContainterTableViewConfirmBlock)(void);

typedef void(^HSRegisterContainterGetCaptchasBlock)(void);

@interface HSRegisterContainterTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneTextFiled;

@property (weak, nonatomic) IBOutlet UITextField *verifyTextFiled;

@property (weak, nonatomic) IBOutlet UIButton *getCaptchasButton;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UITextField *confirmPWTextField;

@property (copy, nonatomic) HSRegisterContainterTableViewConfirmBlock confirmBlock;

@property (copy, nonatomic) HSRegisterContainterGetCaptchasBlock CaptchasBlcok;

@property (strong, nonatomic) UIButton *confirmButton;
@end
