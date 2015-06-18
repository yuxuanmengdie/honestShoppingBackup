//
//  HSMineTopCollectionReusableView.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSMineTopCollectionReusableViewSignActionBlock)(void);

// 我的 顶部的个人信息
@interface HSMineTopCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *signButton;

@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (copy, nonatomic) HSMineTopCollectionReusableViewSignActionBlock signBlock;

/// 签到
- (void)signStatus:(BOOL)isSign;

/// 没有登录时和登录时的欢迎语
- (void)welcomeText:(NSString *)text isLogin:(BOOL)isLogin;

@end
