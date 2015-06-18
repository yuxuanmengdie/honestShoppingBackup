//
//  HSTabBarMidButton.m
//  testFrame
//
//  Created by 张国俗 on 15-5-13.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSTabBarMidButton.h"


@implementation HSTabBarMidButton
{
    NSLayoutConstraint *_heightCon;
}

static const float kSin_PI_4 = 0.707107;
/// 底部高处部分与width关系 topHight = width * per;
static const float kTopPer = kSin_PI_4 - 0.5;
/// 两个圆形之间的距离
static const float kArcRadiusSpacing = 3;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
   
    CGPoint point = CGPointMake(rect.size.width/2.0, (float)kSin_PI_4*rect.size.width);
    UIBezierPath *apath = [UIBezierPath bezierPathWithArcCenter:point
                                                         radius:kSin_PI_4*rect.size.width - 1
                                                     startAngle:0
                                                       endAngle:-M_PI
                                                      clockwise:NO];
    apath.lineWidth = 0.75;
    [_sepColor setStroke];
    [[UIColor whiteColor] setFill];
    [apath stroke];
    [apath fill];

    
    
    
    [_bgColor set];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:point
                                                        radius:kSin_PI_4*rect.size.width - 1 - kArcRadiusSpacing
                                                    startAngle:0
                                                      endAngle:-M_PI
                                                     clockwise:NO];
    [path addLineToPoint:CGPointMake(0, rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    path.lineWidth = 1.0;
//    [kAPPTintColor setStroke];
    [path fill];
    
    
   
}


+ (instancetype)button
{
    return [self buttonWithType:UIButtonTypeCustom];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _bgColor = [UIColor redColor];
    _sepColor = [UIColor yellowColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat wid = CGRectGetWidth(self.frame);
    CGFloat topHei = wid*kTopPer;
    if (_heightCon == nil || _heightCon.constant != topHei) {
        
        for (NSLayoutConstraint *con  in self.constraints) {
            if (con.firstAttribute == NSLayoutAttributeHeight) {
                [self removeConstraint:con];
            }
        }
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _heightCon = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:topHei+kTabBarHeight];
        [self addConstraint:_heightCon];
        
        self.imageEdgeInsets = UIEdgeInsetsMake(topHei/2.0, -2, -topHei/2.0, 2);
        
    }
    
    self.backgroundColor = [UIColor clearColor];
    
}
@end
