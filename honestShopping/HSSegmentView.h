//
//  HSSegmentView.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSSegmentViewActionBlock)(int idx);
/// segment 选择
@interface HSSegmentView : UIView


/// 竖直分割方向颜色
@property (strong, nonatomic) UIColor *verSepColor;

/// 底部水平标记视图选中颜色颜色
@property (strong, nonatomic) UIColor *bottomSelectedColor;

/// 底部水平标记视图常规颜色
@property (strong, nonatomic) UIColor *bottomNormalColor;

/// 按钮的选中标题颜色
@property (strong, nonatomic) UIColor *btnSelectedTitleColor;

/// 按钮的常规标题颜色
@property (strong, nonatomic) UIColor *btnNormalTitleColor;

/*
/// 按钮字体
@property (strong, nonatomic) UIFont *btnFont;
*/

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIView *leftBottomView;

@property (weak, nonatomic) IBOutlet UIView *rightBottomView;

@property (weak, nonatomic) IBOutlet UIView *verSepView;

@property (copy, nonatomic) HSSegmentViewActionBlock actionBlock;


@end
