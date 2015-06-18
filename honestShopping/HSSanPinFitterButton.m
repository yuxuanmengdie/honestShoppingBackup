//
//  HSSanPinFitterButton.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-8.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSanPinFitterButton.h"

@implementation HSSanPinFitterButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self  = [super initWithCoder:aDecoder];
//    
//    if (self) {
//        [self  setUp];
//    }
//    return self;
//}

+ (instancetype)button
{
    return [self buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self fittersetUp];
    }
    
    return self;
}

- (void)fittersetUp
{
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 14;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.contentEdgeInsets = UIEdgeInsetsMake(30, 30, 30, 30);
    _normolTintColor = kAPPTintColor;
    _selectedTintColor = [UIColor whiteColor];
    
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = _normolTintColor.CGColor;
    
    [self setTitleColor:_normolTintColor forState:UIControlStateNormal];
    [self setTitleColor:_selectedTintColor forState:UIControlStateSelected];
    [self setBackgroundImage:[HSPublic ImageWithColor:_selectedTintColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[HSPublic ImageWithColor:_normolTintColor] forState:UIControlStateSelected];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2.0;
}


@end
