//
//  HSCouponSelectedView.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-9.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCouponSelectedView.h"
#import "UIView+HSLayout.h"

@implementation HSCouponSelectedView
{
    NSLayoutConstraint *_bottomConstraint;
    
    NSLayoutConstraint *_tableViewHeightConstraint;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setup];
    }
    
    return self;

}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}


- (void)setup
{
    _tableViewHeight = 0.0;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.text = @"优惠券";
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _couponTextField = [[UITextField alloc] init];
    _couponTextField.placeholder = @"请输入优惠券编码";
    _couponTextField.layer.masksToBounds = YES;
    _couponTextField.layer.cornerRadius = 5.0;
    _couponTextField.layer.borderWidth = 1.0;
    _couponTextField.layer.borderColor = kAPPTintColor.CGColor;
    _couponTextField.borderStyle = UITextBorderStyleRoundedRect;
    _couponTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _couponTextField.font = [UIFont systemFontOfSize:14];
    _couponTextField.delegate = self;
    _couponTextField.keyboardType = UIKeyboardTypePhonePad;
    [self addSubview:_couponTextField];
    
    _verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_verifyButton setTitle:@"验证" forState:UIControlStateNormal];
    [_verifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_verifyButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    _verifyButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _verifyButton.layer.masksToBounds = YES;
    _verifyButton.layer.cornerRadius = 5.0;
    _verifyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_verifyButton addTarget:self action:@selector(verityAction) forControlEvents:UIControlEventTouchUpInside];
    _verifyButton.contentEdgeInsets = UIEdgeInsetsMake(5, 16, 5, 16);
    [self addSubview:_verifyButton];
    
    
    _couponTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _couponTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _couponTableView.tableFooterView = [[UIView alloc] init];
    [self addSubview:_couponTableView];
    
    [self HS_dispacingWithFisrtView:_titleLabel fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:8];
    [self HS_dispacingWithFisrtView:_titleLabel fistatt:NSLayoutAttributeTop secondView:self secondAtt:NSLayoutAttributeTop constant:20];
    [self HS_dispacingWithFisrtView:_titleLabel fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:-8];
    
    [self HS_dispacingWithFisrtView:_couponTextField fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:8];
    [self HS_dispacingWithFisrtView:_couponTextField fistatt:NSLayoutAttributeTop secondView:_titleLabel secondAtt:NSLayoutAttributeBottom constant:8];
    [self HS_dispacingWithFisrtView:_couponTextField fistatt:NSLayoutAttributeTrailing secondView:_verifyButton secondAtt:NSLayoutAttributeLeading constant:-8];
    [self HS_dispacingWithFisrtView:_verifyButton fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:-8];
    [self HS_dispacingWithFisrtView:_couponTextField fistatt:NSLayoutAttributeCenterY secondView:_verifyButton secondAtt:NSLayoutAttributeCenterY constant:0];
    
    [self HS_dispacingWithFisrtView:_couponTableView fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:0];
     [self HS_dispacingWithFisrtView:_couponTableView fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:0];
     [self HS_dispacingWithFisrtView:_couponTableView fistatt:NSLayoutAttributeTop secondView:_couponTextField secondAtt:NSLayoutAttributeBottom constant:8];
    
    _bottomConstraint = [NSLayoutConstraint constraintWithItem:_couponTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    _tableViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_couponTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_tableViewHeight];
    [self addConstraints:@[_bottomConstraint,_tableViewHeightConstraint]];

}

- (void)verityAction
{
    if (self.verifyBlock) {
        self.verifyBlock(_couponTextField.text);
    }
}

- (void)setTableViewHeight:(float)tableViewHeight
{
    if (_tableViewHeight == tableViewHeight) {
        return;
    }
    
    _tableViewHeight = tableViewHeight;
    _tableViewHeightConstraint.constant = tableViewHeight;
    
    if (_bottomConstraint.constant != 0.0) {
        _bottomConstraint.constant = 0;
    }
   else
   {
       _bottomConstraint.constant = -8;
   }

    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    
}

#pragma mark -
#pragma mark textfiled delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
