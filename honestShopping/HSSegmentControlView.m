//
//  HSSegmentControlView.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSegmentControlView.h"
#import "UIView+HSLayout.h"

@interface HSSegmentControlView()
{
    NSUInteger _titlesCount;
    
    UIView *_bottomindicatorView;
    
    NSLayoutConstraint *_bottomViewWidConstraint;
    
    NSLayoutConstraint *_bottomViewLeadingContraint;
}

@end

@implementation HSSegmentControlView

static const int kControlViewTagOri = 700;

static const int kSepViewTag = 510;

- (instancetype)initWithSectionTitles:(NSArray *)titles
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commitInit];
        [self subViewsWithTitles:titles];
        
        _bottomindicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomindicatorView.backgroundColor = _selectedIndicatorColor;
        [self addSubview:_bottomindicatorView];
        _bottomindicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [_bottomindicatorView HS_HeightWithConstant:_indicatorHeight];
       
        if (titles.count == 0) {
             _bottomViewWidConstraint = [NSLayoutConstraint constraintWithItem:_bottomindicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        }
        else
        {
             _bottomViewWidConstraint = [NSLayoutConstraint constraintWithItem:_bottomindicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0/(float)titles.count constant:-2*_indicatorSpacing];
        }
        _bottomViewLeadingContraint = [NSLayoutConstraint constraintWithItem:_bottomindicatorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:_indicatorSpacing];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomindicatorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [self addConstraints:@[_bottomViewLeadingContraint,_bottomViewWidConstraint]];
        
    }
    
    return self;
}

- (void)commitInit
{
    _normalTitleColor = [UIColor blackColor];
    _normalTitleFont = [UIFont systemFontOfSize:16];
    _normalBgColor = [UIColor whiteColor];
    _normalIndicatorColor = [UIColor grayColor];
    
    _selectedTitleColor = [UIColor blackColor];;
    _selectedTitleFont = [UIFont systemFontOfSize:16];
    _selectedBgColor = [UIColor whiteColor];
    _selectedIndicatorColor = [UIColor blackColor];
    
    _indicatorSpacing = 5;
    _indicatorHeight = 2.0;
    
    _currentSelect = -1;
}

- (void)subViewsWithTitles:(NSArray *)titles
{
    _titlesCount = titles.count;
    
    if (titles.count == 0) {
        return;
    }
    
    [titles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
        control.backgroundColor = _normalBgColor;
        [self addSubview:control];
        control.tag = kControlViewTagOri + idx;
        control.translatesAutoresizingMaskIntoConstraints = NO;
        [control addTarget:self action:@selector(segAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = _normalTitleFont;
        titleLabel.textColor = _normalTitleColor;
        [control addSubview:titleLabel];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = obj;
        
        UIView *sepView = [[UIView alloc] initWithFrame:CGRectZero];
        sepView.backgroundColor = _normalIndicatorColor;
        [control addSubview:sepView];
        sepView.tag = kSepViewTag;
        sepView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 约束
        [control HS_centerXYWithSubView:titleLabel];
        //[control addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:control attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
        
        [control HS_dispacingWithFisrtView:control fistatt:NSLayoutAttributeLeading secondView:sepView secondAtt:NSLayoutAttributeLeading constant:-_indicatorSpacing];
        [control HS_dispacingWithFisrtView:sepView fistatt:NSLayoutAttributeBottom secondView:control secondAtt:NSLayoutAttributeBottom constant:0];
        [control HS_centerXWithSubView:sepView];
        [sepView HS_HeightWithConstant:_indicatorHeight];
        
        [self HS_dispacingWithFisrtView:control fistatt:NSLayoutAttributeTop secondView:self secondAtt:NSLayoutAttributeTop constant:0];
        [self HS_dispacingWithFisrtView:control fistatt:NSLayoutAttributeBottom secondView:self secondAtt:NSLayoutAttributeBottom constant:0];
        
    }];
    
    for (int j=0; j<titles.count; j++) {
        // 第一个
         UIView *first = [self viewWithTag:kControlViewTagOri];
        if (j == 0) {
           [self HS_dispacingWithFisrtView:first fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:0];
        }
        
        // 最后一个
        if (j == titles.count - 1) {
            UIView *last = [self viewWithTag:kControlViewTagOri+j];
            [self HS_dispacingWithFisrtView:last fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:0];
            
        }
        
        // 中间的
        if (j > 0 && j < (titles.count)) {
            
            UIView *preView = [self viewWithTag:kControlViewTagOri+j-1];
            UIView *current = [self viewWithTag:kControlViewTagOri+j];
            [self HS_dispacingWithFisrtView:current fistatt:NSLayoutAttributeLeading secondView:preView secondAtt:NSLayoutAttributeTrailing constant:0];
            [self HS_equelWidthWithFirstView:preView secondView:current];
            
        }
        
    }
}

#pragma mark - setter 方法
- (void)setSelectedIndicatorColor:(UIColor *)selectedIndicatorColor
{
    if (selectedIndicatorColor == nil) {
        return;
    }
    _selectedIndicatorColor = selectedIndicatorColor;
    _bottomindicatorView.backgroundColor = selectedIndicatorColor;
}

- (void)setNormalIndicatorColor:(UIColor *)normalIndicatorColor
{
    if (_normalIndicatorColor == nil) {
        return;
    }
    _normalIndicatorColor = normalIndicatorColor;
    
    for (int j=0; j<_titlesCount; j++) {
        UIView *sview = [self viewWithTag:kControlViewTagOri+j];
        UIView *sepview = [sview viewWithTag:kSepViewTag];
        sepview.backgroundColor = normalIndicatorColor;
    }
}

- (void)setSelctedIndex:(NSUInteger)idx
{
    if (idx >= _titlesCount || _currentSelect == idx) { // 超出 或相等时
        return;
    }
    
    UIControl *subView = (UIControl *)[self viewWithTag:kControlViewTagOri+idx];
    [subView sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}

- (void)p_selctedIndex:(NSUInteger)idx
{
    if (idx >= _titlesCount || _currentSelect == idx) { // 超出 或相等时
        return;
    }
    
    UIView *subView = [self viewWithTag:kControlViewTagOri+idx];
    UIView *preView = [self viewWithTag:_currentSelect+kControlViewTagOri];
    [self indicatorLocation:idx/(float)_titlesCount];
    
    subView.backgroundColor = _selectedBgColor;
    preView.backgroundColor = _normalBgColor;
    
    [subView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx1, BOOL *stop) {
        if ([obj isMemberOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)obj;
            lbl.font = _selectedTitleFont;
            lbl.textColor = _selectedTitleColor;
        }
        
    }];
    
    [preView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx1, BOOL *stop) {
        if ([obj isMemberOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)obj;
            lbl.font = _normalTitleFont;
            lbl.textColor = _normalTitleColor;
        }
        
    }];

    _currentSelect = idx;
}


- (void)indicatorLocation:(float)precent
{
    [self layoutIfNeeded];
    float wid = CGRectGetWidth(self.frame);
    
    _bottomViewLeadingContraint.constant = precent*wid + _indicatorSpacing;
    [self layoutIfNeeded];
}

- (void)segAction:(UIControl *)cView
{
    NSUInteger tag = cView.tag - kControlViewTagOri;
    
    [self p_selctedIndex:tag];
    
    if (self.actionBlock) {
        self.actionBlock(tag);
    }
}

@end
