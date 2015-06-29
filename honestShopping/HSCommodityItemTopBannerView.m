//
//  HSCommodityItemTopBannerView.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityItemTopBannerView.h"

@interface HSCommodityItemTopBannerView ()
{
    NSLayoutConstraint *_bannerHeightConstraint;
    
    UIImageView *_sanpinTagImageView;
}

@end

@implementation HSCommodityItemTopBannerView

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
        
        _bannerHeight = 330;
        
        _bannerView = [[FFScrollView alloc] initWithFrame:CGRectZero];
        _bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        _bannerView.imageContentMode = UIViewContentModeScaleAspectFit;
        _bannerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bannerView];
        
        _infoView = [[[NSBundle mainBundle] loadNibNamed:@"HSItemBuyInfoView" owner:nil
                                                options:nil] firstObject];
        _infoView.translatesAutoresizingMaskIntoConstraints = NO;
        [_infoView setNeedsLayout];
        [self addSubview:_infoView];
        
        _sanpinTagImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _sanpinTagImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_sanpinTagImageView];
        
        NSString *vfl1 = @"H:|[_bannerView]|";
        NSString *vfl2 = @"H:|[_infoView]|";
        NSString *vfl3 = @"V:|[_bannerView][_infoView]|";
        NSDictionary *dic = NSDictionaryOfVariableBindings(_bannerView,_infoView);
        NSArray *arr1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
        NSArray *arr2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
        NSArray *arr3 = [NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:dic];
        
        _bannerHeightConstraint = [NSLayoutConstraint constraintWithItem:_bannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_bannerHeight];
        [self addConstraints:arr1];
        [self addConstraints:arr2];
        [self addConstraints:arr3];
        [self addConstraint:_bannerHeightConstraint];
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_sanpinTagImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_sanpinTagImageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8]];
        
        __weak typeof(self) wself = self;
        _bannerView.heightBlock = ^(float height){
            __strong typeof(wself) swself = wself;
            [swself setBannerHeight:height];
            
            if (swself.heightChangeBlcok) {
                swself.heightChangeBlcok();
            }
        };
    }
    
    return self;
}


- (void)setBannerHeight:(float)bannerHeight
{
    if (_bannerHeight == bannerHeight) {
        return;
    }
    
    _bannerHeight = bannerHeight;
    _bannerHeightConstraint.constant = bannerHeight;
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)sanpinImageTag:(HSSanpinCategoryType)sanpinType
{
    NSString *imgName = nil;
    switch (sanpinType) {
        case kNotSanpinType:
        {
            
        }
            break;
        case kYoujiSanpinType:
        {
            imgName = @"icon_sanpin1_60";
        }
            break;
        case kLvseSanpinType:
        {
            imgName = @"icon_sanpin2_60";
        }
            break;
        case kWugonghaiSanpinType:
        {
            imgName = @"icon_sanpin3_60";
        }
            break;
        case kDiliSanpinType:
        {
            imgName = @"icon_sanpin4_60";
        }
            break;

        default:
            break;
    }
    
    if (imgName.length > 0) {
        UIImage *img = [UIImage imageNamed:imgName];
        _sanpinTagImageView.image = img;
        _infoView.titleTrailingConstraint.constant = 16 + 3 + img.size.width;
        [_infoView updateConstraintsIfNeeded];
        [_infoView layoutIfNeeded];
    }
}

- (void)layoutSubviews {
    // Custom code which potentially messes with constraints
    [super layoutSubviews]; // No code after this and this is called last
}

@end
