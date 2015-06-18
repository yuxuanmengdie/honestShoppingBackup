//
//  HSSettleView.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSettleView.h"
#import "UIView+HSLayout.h"

@implementation HSSettleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)awakeFromNib
{
    [_settltButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_settltButton setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    _textLabel.textColor = [UIColor redColor];
    _preLabel.textColor = kAPPTintColor;
    _settltButton.layer.masksToBounds = YES;
    _settltButton.layer.cornerRadius = 5.0;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        subView.backgroundColor = [UIColor clearColor];
        [self addSubview:subView];
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [self HS_edgeFillWithSubView:subView];
        
    }
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        subView.backgroundColor = [UIColor clearColor];
        [self addSubview:subView];
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [self HS_edgeFillWithSubView:subView];
        
    }
    
    return self;
}

- (IBAction)settleAction:(id)sender {
    if (self.settleBlock) {
        self.settleBlock();
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0, kTabBarHeight);
}

@end
