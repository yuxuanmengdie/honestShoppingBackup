//
//  HSSegmentView.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSegmentView.h"
#import "UIView+HSLayout.h"

@implementation HSSegmentView
{
    int _currentIdx;
}

static const int kButtonTagOri = 500;
static const int kBottomViewTagOri = 800;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) awakeFromNib
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    
    if (self) {
        
        UIView *sview = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        [self addSubview:sview];
        sview.translatesAutoresizingMaskIntoConstraints = NO;
        sview.backgroundColor = [UIColor clearColor];
        [self HS_edgeFillWithSubView:sview];
        [self commitInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self  = [super initWithCoder:aDecoder];
    
    if (self) {
        
        UIView *sview = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        [self addSubview:sview];
        sview.translatesAutoresizingMaskIntoConstraints = NO;
        sview.backgroundColor = [UIColor clearColor];
        [self HS_edgeFillWithSubView:sview];
        [self commitInit];
    }
    
    return self;

}

- (void)commitInit
{
    _verSepColor = [UIColor lightGrayColor];
    _bottomNormalColor = [UIColor lightGrayColor];
    _bottomSelectedColor = kAPPTintColor;
    _btnNormalTitleColor = [UIColor blackColor];
    _btnSelectedTitleColor = kAPPTintColor;
    
    [_leftButton setTitleColor:_btnSelectedTitleColor forState:UIControlStateSelected];
    [_leftButton setTitleColor:_btnNormalTitleColor forState:UIControlStateNormal];
    _leftButton.tag = kButtonTagOri;
    
    [_rightButton setTitleColor:_btnSelectedTitleColor forState:UIControlStateSelected];
    [_rightButton setTitleColor:_btnNormalTitleColor forState:UIControlStateNormal];
    _rightButton.tag = kButtonTagOri + 1;
    
    _leftBottomView.tag = kBottomViewTagOri;
    _rightButton.tag = kBottomViewTagOri + 1;
    
    _currentIdx = 0;
    _leftButton.selected = YES;
    _leftBottomView.backgroundColor = _bottomSelectedColor;
    _rightBottomView.backgroundColor = _bottomNormalColor;

}

- (IBAction)leftAction:(id)sender {
    [self currentIdxChange:0];
}

- (IBAction)rightAction:(id)sender {
    [self currentIdxChange:1];
}

- (void)currentIdxChange:(int)idx
{
    if (_currentIdx == idx) {
        return;
    }
    
    if (_currentIdx >= 0) {
        UIButton *lastButton = (UIButton *)[self viewWithTag:kButtonTagOri+_currentIdx];
        lastButton.selected = NO;
        UIView *lastView = [self viewWithTag:kBottomViewTagOri+_currentIdx];
        lastView.backgroundColor = _bottomNormalColor;
      
    }
    
    UIButton *cuButton = (UIButton *)[self viewWithTag:kButtonTagOri+idx];
    cuButton.selected = YES;
    UIView *currView = [self viewWithTag:kBottomViewTagOri+idx];
    currView.backgroundColor = _bottomSelectedColor;

    
    _currentIdx = idx;
    
    if (self.actionBlock) {
        self.actionBlock(idx);
    }
    
}


@end
