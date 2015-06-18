//
//  HSSanPinfitterView.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-8.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSanPinfitterView.h"
#import "UIView+HSLayout.h"
#import "HSSanPinFitterButton.h"

static const int kFitterBtnTagOri = 500;

@interface HSSanPinfitterView ()
{
    int _lastSelected;
}

@end

@implementation HSSanPinfitterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setUp];
    }
    return self;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    _edgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    _itemSpacing = 8;
    
    _lastSelected = -1;
}


- (void)buttonWithTitles:(NSArray *)titles
{
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    
    if (titles.count < 1) {
        return;
    }
    
    [titles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        HSSanPinFitterButton *btn = [[HSSanPinFitterButton alloc] initWithFrame:CGRectZero];
        [btn setTitle:obj forState:UIControlStateNormal];
        btn.tag = kFitterBtnTagOri + idx;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:btn];
        NSLayoutConstraint *con = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:btn attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        [btn addConstraint:con];

    }];
    
 
    for (int j=1; j<titles.count; j++) {
        HSSanPinFitterButton *latBtn = (HSSanPinFitterButton *)[self viewWithTag:kFitterBtnTagOri + j - 1];
        HSSanPinFitterButton *btn = (HSSanPinFitterButton *)[self viewWithTag:kFitterBtnTagOri + j];
        [self HS_alignWithFirstView:latBtn secondView:btn layoutAttribute:NSLayoutAttributeTop constat:0];
        [self HS_equelWidthWithFirstView:latBtn secondView:btn];
        [self HS_dispacingWithFisrtView:latBtn fistatt:NSLayoutAttributeTrailing secondView:btn secondAtt:NSLayoutAttributeLeading constant:-_itemSpacing];
        
        if (j == titles.count - 1) { /// 最后一个
            [self HS_dispacingWithFisrtView:self fistatt:NSLayoutAttributeTrailing secondView:btn secondAtt:NSLayoutAttributeTrailing constant:_edgeInsets.right];
        }
    }
    
    HSSanPinFitterButton *first = (HSSanPinFitterButton *)[self viewWithTag:kFitterBtnTagOri ];
    [self HS_dispacingWithFisrtView:self fistatt:NSLayoutAttributeLeading secondView:first secondAtt:NSLayoutAttributeLeading constant:-_edgeInsets.left];
    [self HS_dispacingWithFisrtView:self fistatt:NSLayoutAttributeTop secondView:first secondAtt:NSLayoutAttributeTop constant:-_edgeInsets.top];
    [self HS_dispacingWithFisrtView:self fistatt:NSLayoutAttributeBottom secondView:first secondAtt:NSLayoutAttributeBottom constant:_edgeInsets.bottom];
    
    /// sepView
    _sepView = [[UIView alloc] init];
    _sepView.translatesAutoresizingMaskIntoConstraints = NO;
    _sepView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_sepView];
    [self HS_dispacingWithFisrtView:_sepView fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:0];
    [self HS_dispacingWithFisrtView:_sepView fistatt:NSLayoutAttributeBottom secondView:self secondAtt:NSLayoutAttributeBottom constant:0];
    [self HS_centerXWithSubView:_sepView];
    [_sepView HS_HeightWithConstant:0.5];

}


- (void)btnAction:(HSSanPinFitterButton *)btn
{
    int idx = (int)btn.tag - kFitterBtnTagOri;
    
    if (idx == _lastSelected) { /// 相同点击
        return;
    }
    
    HSSanPinFitterButton *latBtn = (HSSanPinFitterButton *)[self viewWithTag:kFitterBtnTagOri + _lastSelected];
    latBtn.selected = NO;
    btn.selected = YES;
    _lastSelected = idx;
    if (self.actionBlock) {
        self.actionBlock(idx);
    }
}

- (void)beginActionWithIdx:(int)idx;
{
    HSSanPinFitterButton *btn = (HSSanPinFitterButton *)[self viewWithTag:kFitterBtnTagOri + idx];
    
    if (btn == nil) {
        return;
    }
    
    _lastSelected = idx;
    btn.selected = YES;
    if (self.actionBlock) {
        self.actionBlock(idx);
    }


}
@end
