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

@interface HSBuyNumView : UIView

@property (weak, nonatomic) IBOutlet PKYStepper *stepper;

@property (weak, nonatomic) IBOutlet UIButton *buyBtn;

@property (weak, nonatomic) IBOutlet UIButton *collectBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepperWidthConstrait;

- (IBAction)buyBtnAction:(id)sender;

- (IBAction)collectBtnAction:(id)sender;


@property (copy, nonatomic) BuyNumBuyBlock buyBlock;

@property (copy, nonatomic) BuyNumCollectBlock collectBlock;
@end
