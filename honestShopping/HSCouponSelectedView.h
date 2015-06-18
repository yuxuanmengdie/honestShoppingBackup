//
//  HSCouponSelectedView.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-9.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSCouponVerifyBlock)(NSString *couponID);

@interface HSCouponSelectedView : UIView<UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UITableView *couponTableView;

@property (strong, nonatomic) UITextField *couponTextField;

@property (strong, nonatomic) UIButton *verifyButton;

@property (assign, nonatomic) float tableViewHeight;

@property (copy, nonatomic) HSCouponVerifyBlock verifyBlock;

@end
