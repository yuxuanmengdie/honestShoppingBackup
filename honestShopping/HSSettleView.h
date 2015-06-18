//
//  HSSettleView.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSSettleActionBlock)(void);
/// 底部结算的view
@interface HSSettleView : UIView

@property (weak, nonatomic) IBOutlet UILabel *preLabel;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIButton *settltButton;

@property (copy, nonatomic) HSSettleActionBlock settleBlock;
@end
