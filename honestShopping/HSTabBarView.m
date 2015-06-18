//
//  HSTabBarView.m
//  testFrame
//
//  Created by 张国俗 on 15-5-13.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSTabBarView.h"
#import "HSTabBarMidButton.h"
#import "UIView+HSLayout.h"

@interface HSTabBarView ()
{
    int _lastSelected;
}

@end

@implementation HSTabBarView

static const int kButtonOriTag = 500;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

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
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bgView];
    
    [self HS_dispacingWithFisrtView:bgView fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:0];
    [self HS_dispacingWithFisrtView:bgView fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:0];
    [self HS_dispacingWithFisrtView:bgView fistatt:NSLayoutAttributeBottom secondView:self secondAtt:NSLayoutAttributeBottom constant:0];
    [bgView HS_HeightWithConstant:kTabBarHeight];
    
    
    NSArray *normalIcon = @[@"icon_tabbar1_unsel",@"icon_tabbar2_unsel",@"icon_tabbar3_unsel",@"icon_tabbar4_unsel",@"icon_tabbar5_unsel"];
    NSArray *selectedIcon = @[@"icon_tabbar1",@"icon_tabbar2",@"icon_tabbar3_unsel",@"icon_tabbar4",@"icon_tabbar5"];
    NSArray *titleArr = @[@"首页",@"发现",@"",@"我的",@"更多"];
    
    for (int j=0; j<5; j++) {
        UIButton *btn;
        if (j == 2) {
            btn = [HSTabBarMidButton button];
        }
        else
        {
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
        }
        btn.tag = kButtonOriTag + j;
        [btn setTitle:titleArr[j] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleColor:kAPPTintColor forState:UIControlStateSelected];
        UIImage *normalImage = [UIImage imageNamed:normalIcon[j]];
        [btn setImage:normalImage forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:selectedIcon[j]] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        btn.backgroundColor = [UIColor whiteColor];
 //       [btn setBackgroundImage:[public  ImageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
        [self addSubview:btn];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (j == 2) { /// 中间的
            [self HS_dispacingWithFisrtView:btn fistatt:NSLayoutAttributeTop secondView:self secondAtt:NSLayoutAttributeTop constant:0];
            btn.backgroundColor = [UIColor clearColor];
            
            HSTabBarMidButton *midBtn = (HSTabBarMidButton *)btn;
            midBtn.bgColor = kAPPTintColor;
            midBtn.sepColor = [UIColor lightGrayColor];
            
        }
        else
        {
            NSString *btnTitle = titleArr[j];
            CGSize titleSize = [btnTitle sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:10]}];
            btn.titleEdgeInsets = UIEdgeInsetsMake(normalImage.size.height/2.0+5,-(normalImage.size.width)/2.0,-normalImage.size.height/2.0-5,(normalImage.size.width)/2.0);
            btn.imageEdgeInsets = UIEdgeInsetsMake(-5, titleSize.width/2.0, 5, -titleSize.width/2.0);
            UIView *sepView = [[UIView alloc] initWithFrame:CGRectZero];
            [btn addSubview:sepView];
            sepView.backgroundColor = [UIColor lightGrayColor];
            sepView.translatesAutoresizingMaskIntoConstraints = NO;
            [btn HS_dispacingWithFisrtView:btn fistatt:NSLayoutAttributeLeading secondView:sepView secondAtt:NSLayoutAttributeLeading constant:0];
            [btn HS_dispacingWithFisrtView:btn fistatt:NSLayoutAttributeTop secondView:sepView secondAtt:NSLayoutAttributeTop constant:0];
            [btn HS_dispacingWithFisrtView:btn fistatt:NSLayoutAttributeTrailing secondView:sepView secondAtt:NSLayoutAttributeTrailing constant:0];
            [sepView HS_HeightWithConstant:0.5];
            
            [btn HS_HeightWithConstant:kTabBarHeight];
        }
        [self HS_dispacingWithFisrtView:btn fistatt:NSLayoutAttributeBottom secondView:self secondAtt:NSLayoutAttributeBottom constant:0];
        
    }
    
    UIButton *firstBtn = (UIButton *)[self viewWithTag:kButtonOriTag];
    [self HS_dispacingWithFisrtView:firstBtn fistatt:NSLayoutAttributeLeading secondView:self secondAtt:NSLayoutAttributeLeading constant:0];
    
    for (int j=1; j<5; j++) {
        UIButton *preBtn = (UIButton *)[self viewWithTag:kButtonOriTag+j-1];
        UIButton *currentBtn = (UIButton *)[self viewWithTag:kButtonOriTag+j];
        
        [self HS_equelWidthWithFirstView:preBtn secondView:currentBtn];
        [self HS_dispacingWithFisrtView:preBtn fistatt:NSLayoutAttributeTrailing secondView:currentBtn secondAtt:NSLayoutAttributeLeading constant:0];
        
        if (j == 4) {
            [self HS_dispacingWithFisrtView:currentBtn fistatt:NSLayoutAttributeTrailing secondView:self secondAtt:NSLayoutAttributeTrailing constant:0];
            
        }
        
    }
    firstBtn.selected = YES;
    _lastSelected = 0;

    
}

- (void)btnAction:(UIButton *)btn
{
    int tag = (int)btn.tag - kButtonOriTag;
    
    if (tag == _lastSelected) {
        return;
    }
    UIButton *lastBtn = (UIButton *)[self viewWithTag:kButtonOriTag+_lastSelected];
    lastBtn.selected = NO;
    btn.selected = YES;
    _lastSelected = tag;
    
    if (self.actionBlock) {
        self.actionBlock(tag);
    }
    
}
@end
