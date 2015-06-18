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
    _stepper.stepInterval = 1.0;
    _stepper.minimum = 1.0;
    _stepper.value = 1.0;
    __weak typeof(_stepper) weakStepper = _stepper;
    [_stepper setValueChangedCallback:^(PKYStepper *stepper, float newValue){
        weakStepper.countLabel.text = [NSString stringWithFormat:@"%d",(int)newValue];
        
    }];
    
//    [_stepper setIncrementCallback:^(PKYStepper *stepper, float newValue){
//        if (newValue > weakStepper.maximum) {
//            [HSPublic showHudInWindowWithText:@"亲，不能在多了"];
//        }
//    }];
//    [_stepper setDecrementCallback:^(PKYStepper *stepper, float newValue){
//        if (newValue < weakStepper.minimum) {
//            [HSPublic showHudInWindowWithText:@"亲，不能在少了"];
//        }
//    }];
    
    [_stepper setBorderColor:kAPPTintColor];
    [_stepper setLabelTextColor:kAPPTintColor];
    [_stepper setButtonTextColor:kAPPTintColor forState:UIControlStateNormal];
    [_stepper setup];
    
    [_buyBtn setTitle:@"立刻购买" forState:UIControlStateNormal];
    [_buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyBtn setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    _buyBtn.layer.masksToBounds = YES;
    _buyBtn.layer.cornerRadius = 5.0;
    
    [_collectBtn setTitle:@"" forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"icon_favorite_Sel30"] forState:UIControlStateSelected];
    [_collectBtn setImage:[UIImage imageNamed:@"icon_favorite_unSel30"] forState:UIControlStateNormal];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
        
        [self addSubview:subView];
        subView.backgroundColor = [UIColor clearColor];
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


- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0, 49);
}
@end
