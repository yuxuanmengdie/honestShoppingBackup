//
//  HSExpressProgressView.h
//  honestShopping
//
//  Created by 张国俗 on 15-12-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSExpressProgressView : UIView

// 顶部间距
@property (nonatomic, assign) CGFloat topDistance;
// 内部圆颜色
@property (nonatomic, strong) UIColor *circleColor;
// 外圈颜色
@property (nonatomic, strong) UIColor *outsideColor;
// 线条颜色
@property (nonatomic, strong) UIColor *lineColor;

- (void)lastedExpressStatus:(BOOL)isLasted;

@end
