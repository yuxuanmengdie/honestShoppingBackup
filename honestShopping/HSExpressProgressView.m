//
//  HSExpressProgressView.m
//  honestShopping
//
//  Created by 张国俗 on 15-12-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSExpressProgressView.h"

@interface HSExpressProgressView () {
    UIView *_topView;
    UIView *_outsideView;
    UIView *_insideView;
    UIView *_bottomView;
    NSLayoutConstraint *_topConstraint;
    NSLayoutConstraint *_outWidConstraint;
}

@end

@implementation HSExpressProgressView

static const float kInsideDis = 2.0;

static const float kOutsideWidth = 14.0;

static const float kNoLastedWidth = 5.0;

static const float kLineWidth = 0.5;
// topView 默认高度
static const float kTopViewHeight = 8.0;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commitInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commitInit];
    }
    
    return self;
}

- (void)lastedExpressStatus:(BOOL)isLasted {
    
    if (isLasted) {
        _insideView.hidden = NO;
        _topView.hidden = YES;
        _outWidConstraint.constant = kOutsideWidth;
        
    }else {
        _insideView.hidden = YES;
        _topView.hidden = NO;
        _outWidConstraint.constant = kNoLastedWidth;
    }
    [_outsideView layoutIfNeeded];
}


- (void)commitInit {
    _outsideColor = kAPPLightGreenColor;
    _circleColor = kAPPTintColor;
    _lineColor = [UIColor lightGrayColor];
    
    _topView = [[UIView alloc] initWithFrame:CGRectZero];
    _topView.backgroundColor = _lineColor;
    _topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_topView];
    
    _outsideView = [[UIView alloc] initWithFrame:CGRectZero];
    _outsideView.backgroundColor = _outsideColor;
    _outsideView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_outsideView];
    
    _insideView = [[UIView alloc] initWithFrame:CGRectZero];
    _insideView.backgroundColor = _circleColor;
    _insideView.translatesAutoresizingMaskIntoConstraints = NO;
    [_outsideView addSubview:_insideView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomView.backgroundColor = _lineColor;
    _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_bottomView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView][_outsideView(hei)][_bottomView]|" options:NSLayoutFormatAlignAllCenterX metrics:@{@"hei":[NSNumber numberWithFloat:kOutsideWidth]} views:NSDictionaryOfVariableBindings(_topView,_outsideView,_bottomView)]];
    _topConstraint = [NSLayoutConstraint constraintWithItem:_topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kTopViewHeight];
    _outWidConstraint = [NSLayoutConstraint constraintWithItem:_outsideView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kOutsideWidth];
    [self addConstraint:_outWidConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_insideView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_outsideView  attribute:NSLayoutAttributeLeading multiplier:1.0 constant:kInsideDis]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_insideView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_outsideView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_insideView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_outsideView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    _outsideView.layer.masksToBounds = YES;
    _outsideView.layer.cornerRadius = kOutsideWidth/2.0;
    
    _insideView.layer.masksToBounds = YES;
    _insideView.layer.cornerRadius = (kOutsideWidth-2*kInsideDis)/2.0;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float wid = _outWidConstraint.constant;
    _outsideView.layer.masksToBounds = YES;
    _outsideView.layer.cornerRadius = wid/2.0;
    
    _insideView.layer.masksToBounds = YES;
    if (!_insideView.hidden) {
         _insideView.layer.cornerRadius = (wid-2*kInsideDis)/2.0;
    }
}

#pragma mark - set方法
- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    _insideView.backgroundColor = circleColor;
}

- (void)setOutsideColor:(UIColor *)outsideColor {
    _outsideColor = outsideColor;
    _outsideView.backgroundColor = outsideColor;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    _topView.backgroundColor = lineColor;
    _bottomView.backgroundColor = lineColor;
}

@end
