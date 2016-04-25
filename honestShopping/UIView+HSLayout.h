//
//  UIView+HSLayout.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 自动布局 类目
@interface UIView (HSLayout)

/// 子视图填充到父视图中
- (void)HS_edgeFillWithSubView:(UIView *)subView;

/// 在父视图中居中
- (void)HS_centerXYWithSubView:(UIView *)subView;

/// 水平居中
- (void)HS_centerXWithSubView:(UIView *)subView;

/// 竖直居中
- (void)HS_centerYWithSubView:(UIView *)subView;

/// 方向上间隔距离
- (void)HS_dispacingWithFisrtView:(UIView *)firstView fistatt:(NSLayoutAttribute)firstAtt secondView:(UIView *)secView secondAtt:(NSLayoutAttribute)secondAtt constant:(CGFloat)constant;

/// 宽度
- (void)HS_widthWithConstant:(CGFloat)width;

/// 高度
- (void)HS_HeightWithConstant:(CGFloat)height;

/// 两个子视图等宽
- (void)HS_equelWidthWithFirstView:(UIView *)firstView secondView:(UIView *)secondView;

/// 两个子视图等高
- (void)HS_equelHeightWithFirstView:(UIView *)firstView secondView:(UIView *)secondView;

/// 子视图 对齐方式
- (void)HS_alignWithFirstView:(UIView *)firstView secondView:(UIView *)secondView layoutAttribute:(NSLayoutAttribute)att constat:(CGFloat)constant;
@end
