//
//  HSBuyNumView.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-31.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKYStepper.h"
@class PKYStepper;

/// 购买的block
typedef void(^BuyNumBuyBlock)(int);

/// 收藏的block
typedef void(^BuyNumCollectBlock)(UIButton *sender);

// 打开购物车
typedef void(^BuyNumCartBlcok)(void);

@interface HSBuyNumView : UIView

@property (weak, nonatomic) IBOutlet UIView *numBackView;

@property (weak, nonatomic) IBOutlet PKYStepper *stepper;

@property (weak, nonatomic) IBOutlet UIButton *buyBtn;

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;

@property (weak, nonatomic) IBOutlet UIButton *cartBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepperWidthConstrait;

@property (copy, nonatomic) BuyNumBuyBlock buyBlock;

@property (copy, nonatomic) BuyNumCollectBlock collectBlock;

@property (copy, nonatomic) BuyNumCartBlcok cartBlock;

- (IBAction)buyBtnAction:(id)sender;

- (IBAction)collectBtnAction:(id)sender;

// 根据是否添加到购物车，修改btn状态
- (void)collectTitleWithStatus:(BOOL)isCollect;


@end
