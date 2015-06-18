//
//  HSSanPinfitterView.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-8.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSSanPinfitterViewActionBlock)(int idx);

@interface HSSanPinfitterView : UIView

/// 距离父视图的edge 默认都为8
@property (assign, nonatomic) UIEdgeInsets edgeInsets;

/// 按钮之间的间距， 默认为8
@property (assign, nonatomic) CGFloat itemSpacing;

/// 分割视图 默认高度0.5
@property (strong, nonatomic) UIView *sepView;

@property (copy, nonatomic) HSSanPinfitterViewActionBlock actionBlock;

/// 根据数据赋值 动态增加button数量
- (void)buttonWithTitles:(NSArray *)titles;

/// 开始响应
- (void)beginActionWithIdx:(int)idx;

@end
