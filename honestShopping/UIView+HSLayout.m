//
//  UIView+HSLayout.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "UIView+HSLayout.h"

@implementation UIView (HSLayout)

- (void)HS_edgeFillWithSubView:(UIView *)subView
{
    if (subView.superview != self) {
        return;
    }
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *vfl1 = @"H:|[subView]|";
    NSString *vfl2 = @"V:|[subView]|";
    NSDictionary *dic = NSDictionaryOfVariableBindings(subView);
    NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
    NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
    [self addConstraints:cons1];
    [self addConstraints:cons2];
}

-  (void)HS_centerXYWithSubView:(UIView *)subView
{
    if (subView.superview != self) {
        return;
    }
    
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraints:@[centerX,centerY]];

}


- (void)HS_dispacingWithFisrtView:(UIView *)firstView fistatt:(NSLayoutAttribute)firstAtt secondView:(UIView *)secView secondAtt:(NSLayoutAttribute)secondAtt constant:(CGFloat)constant;
{
    NSLayoutConstraint *con = [NSLayoutConstraint constraintWithItem:firstView attribute:firstAtt relatedBy:NSLayoutRelationEqual toItem:secView attribute:secondAtt multiplier:1.0 constant:constant];
    [self addConstraint:con];
}


/// 宽度
- (void)HS_widthWithConstant:(CGFloat)width;
{
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *widthCon = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    [self addConstraint:widthCon];
}

/// 高度
- (void)HS_HeightWithConstant:(CGFloat)height
{
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *con = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self addConstraint:con];

}

/// 水平居中
- (void)HS_centerXWithSubView:(UIView *)subView;
{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *con = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:con];
}

/// 竖直居中
- (void)HS_centerYWithSubView:(UIView *)subView
{
//    subView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *con = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraint:con];

}

- (void)HS_equelWidthWithFirstView:(UIView *)firstView secondView:(UIView *)secondView
{
    NSLayoutConstraint *widCon = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self addConstraint:widCon];
}

- (void)HS_equelHeightWithFirstView:(UIView *)firstView secondView:(UIView *)secondView
{
    NSLayoutConstraint *HeiCon = [NSLayoutConstraint constraintWithItem:firstView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:secondView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self addConstraint:HeiCon];
}

- (void)HS_alignWithFirstView:(UIView *)firstView secondView:(UIView *)secondView layoutAttribute:(NSLayoutAttribute)att constat:(CGFloat)constant
{
    NSLayoutConstraint *align = [NSLayoutConstraint constraintWithItem:firstView attribute:att relatedBy:NSLayoutRelationEqual toItem:secondView attribute:att multiplier:1.0 constant:constant];
    [self addConstraint:align];
}

@end
