//
//  HSSegmentControlView.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSSegmentControlActionBlcok)(NSUInteger idx);

@interface HSSegmentControlView : UIView

// 标题颜色 默认 blackColor
@property (nonatomic, strong) UIColor *normalTitleColor;

@property (nonatomic, strong) UIColor *selectedTitleColor;

// 字体 默认 system 16
@property (nonatomic, strong) UIFont *normalTitleFont;

@property (nonatomic, strong) UIFont *selectedTitleFont;

// 背景色 默认 whiteColor;
@property (nonatomic, strong) UIColor *normalBgColor;

@property (nonatomic, strong) UIColor *selectedBgColor;

// 指示器 默认颜色 [UIColor grayColor];
@property (nonatomic, strong) UIColor *normalIndicatorColor;
// 默认颜色 [UIColor blackColor];
@property (nonatomic, strong) UIColor *selectedIndicatorColor;

// 指示器 默认高度 1
@property (nonatomic, assign, readonly) float indicatorHeight;

// 指示器 边距 0
@property (nonatomic, assign, readonly) float indicatorSpacing;

@property (nonatomic, assign, readonly) NSInteger currentSelect;

@property (copy, nonatomic) HSSegmentControlActionBlcok actionBlock;

- (instancetype)initWithSectionTitles:(NSArray *)titles;

- (void)setSelctedIndex:(NSUInteger)idx;

// 指示器的百分比
- (void)indicatorLocation:(float)precent;
@end
