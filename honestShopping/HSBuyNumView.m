//
//  HSBuyNumView.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-31.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBuyNumView.h"
#import "PKYStepper.h"

@implementation HSBuyNumView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    _stepper.stepInterval = 1.0;
    _stepper.minimum = 1.0;
    _stepper.value = 1.0;
    __weak typeof(_stepper) weakStepper = _stepper;
    [_stepper setValueChangedCallback:^(PKYStepper *stepper, float newValue){
        weakStepper.countLabel.text = [NSString stringWithFormat:@"%d",(int)newValue];
        
    }];
    
    [_stepper setButtonWidth:24.0f];
    [_stepper setBorderColor:kAPPTintColor];
    [_stepper setLabelTextColor:kAPPTintColor];
    [_stepper setButtonTextColor:kAPPTintColor forState:UIControlStateNormal];
//    [_stepper setButtonFont:[UIFont systemFontOfSize:16]];
    [_stepper setup];
    
    [_buyBtn setTitle:@"立刻购买" forState:UIControlStateNormal];
    [_buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyBtn setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    _buyBtn.layer.masksToBounds = YES;
    _buyBtn.layer.cornerRadius = 5.0;
    _buyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [_collectBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [_collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_collectBtn setBackgroundImage:[HSPublic ImageWithColor:kAPPLightGreenColor] forState:UIControlStateNormal];
    _collectBtn.layer.masksToBounds = YES;
    _collectBtn.layer.cornerRadius = 5.0;
    _collectBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [_collectBtn setImage:[UIImage imageNamed:@"icon_favorite_Sel30"] forState:UIControlStateSelected];
//    [_collectBtn setImage:[UIImage imageNamed:@"icon_favorite_unSel30"] forState:UIControlStateNormal];
    
    [_cartBtn setBackgroundImage:[HSPublic ImageWithColor:kAPPLightGreenColor] forState:UIControlStateNormal];
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        [self addSubview:subView];
        subView.backgroundColor = [UIColor clearColor];
        subView.clipsToBounds = NO;
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *vfl1 = @"H:|[subView]|";
        NSString *vfl2 = @"V:|[subView]|";
        NSDictionary *dic = NSDictionaryOfVariableBindings(subView);
        
        NSArray *con1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
        NSArray *con2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
        [self addConstraints:con1];
        [self addConstraints:con2];
        
    }
    return self;
}

- (void)collectTitleWithStatus:(BOOL)isCollect
{
    NSString *str = @"加入购物车";
    _collectBtn.enabled = YES;
    
    if (isCollect) {
        str = @"已在购物车";
        _collectBtn.enabled = NO;
    }
    
    [_collectBtn setTitle:str forState:UIControlStateNormal];
}
#pragma mark - target action
- (IBAction)buyBtnAction:(id)sender {
    
    if (self.buyBlock) {
        self.buyBlock([_stepper.countLabel.text intValue]);
    }
}

- (IBAction)collectBtnAction:(id)sender {
    
    if (self.collectBlock) {
        self.collectBlock(sender);
    }
}

- (IBAction)cartAction:(id)sender {
    
    if (self.cartBlock) {
        self.cartBlock();
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0, 44);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutIfNeeded];
    _cartBtn.layer.masksToBounds = YES;
    _cartBtn.layer.cornerRadius = MIN(CGRectGetWidth(_cartBtn.frame), CGRectGetHeight(_cartBtn.frame))/2.0;
}
@end
