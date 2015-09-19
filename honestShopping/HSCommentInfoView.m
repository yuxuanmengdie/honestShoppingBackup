//
//  HSCommentInfoView.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommentInfoView.h"
#import "HSCommentInfoModel.h"
#import "UIView+HSLayout.h"

@interface HSCommentInfoView ()

@property (weak, nonatomic) IBOutlet UIView *rightView;

@property (weak, nonatomic) IBOutlet UIView *holderView;

@property (weak, nonatomic) IBOutlet UIView *goodView;

@property (weak, nonatomic) IBOutlet UIView *normalView;

@property (weak, nonatomic) IBOutlet UIView *badView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *badWidConstraint;
@end

@implementation HSCommentInfoView

- (void)awakeFromNib
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self commitInit];
    }
    
    return self;

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self commitInit];
    }
    
    return self;

}

- (void)commitInit
{
    UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    
    subView.backgroundColor = [UIColor clearColor];
    [self addSubview:subView];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [self HS_edgeFillWithSubView:subView];
    
    _percentLabel.text = @"0%";
    
    _goodLabel.text = @"很好:";
    _normalLabel.text = @"一般:";
    _badLabel.text = @"失望:";
    
    _goodLabel.textColor = kAPPLightGreenColor;
    _normalLabel.textColor = kAppYellowColor;
    _badLabel.textColor = [UIColor lightGrayColor];
    
    _goodView.backgroundColor = _goodLabel.textColor;
    _normalView.backgroundColor = _normalLabel.textColor;
    _badView.backgroundColor = _badLabel.textColor;
    
    _goodCountLabel.textColor = _goodLabel.textColor;
    _normalCountLabel.textColor = _normalLabel.textColor;
    _badCountLabel.textColor = _badLabel.textColor;
    
    _totalLabel.textColor = _goodLabel.textColor;
    
    _goodCountLabel.text = @"(0)";
    _normalCountLabel.text = @"(0)";
    _badCountLabel.text = @"(0)";
    _totalLabel.text = @"全部\n(0)";
    
}

- (void)setUpWithInfoModel:(HSCommentInfoModel *)infoModel
{
    _percentLabel.text = [NSString stringWithFormat:@"%d%%",infoModel.percent];
    _totalLabel.text = [NSString stringWithFormat:@"全部\n(%d)",infoModel.total];
    _goodCountLabel.text = [NSString stringWithFormat:@"(%d)",infoModel.good];
    _normalCountLabel.text = [NSString stringWithFormat:@"(%d)",infoModel.normal];;
    _badCountLabel.text = [NSString stringWithFormat:@"(%d)",infoModel.bad];
    
    _holderView.translatesAutoresizingMaskIntoConstraints = NO;
    _goodView.translatesAutoresizingMaskIntoConstraints = NO;
    _normalView.translatesAutoresizingMaskIntoConstraints = NO;
    _badView.translatesAutoresizingMaskIntoConstraints = NO;

    
    // 总数为0时，表示 good，normal，bad， width = 0；
    [self p_removeOldConstraint];
    if (0 == infoModel.total) {
        _goodWidConstraint = [NSLayoutConstraint constraintWithItem:_goodView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        _normalWidConstraint = [NSLayoutConstraint constraintWithItem:_normalView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        _badWidConstraint = [NSLayoutConstraint constraintWithItem:_badView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        _goodWidConstraint.priority = 50;
        _normalWidConstraint.priority = 50;
        _badWidConstraint.priority = 50;

        [_rightView addConstraints:@[_goodWidConstraint,_normalWidConstraint,_badWidConstraint]];
    }
    else
    {
        // 取数量最多的做分母
        int maxCount = MAX(MAX(infoModel.good, infoModel.normal), infoModel.bad);
        
        _goodWidConstraint = [NSLayoutConstraint constraintWithItem:_goodView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_holderView attribute:NSLayoutAttributeWidth multiplier:(float)infoModel.good/(float)maxCount constant:0];
        _normalWidConstraint = [NSLayoutConstraint constraintWithItem:_normalView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_holderView attribute:NSLayoutAttributeWidth multiplier:(float)infoModel.normal/(float)maxCount constant:0];
        _badWidConstraint = [NSLayoutConstraint constraintWithItem:_badView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_holderView attribute:NSLayoutAttributeWidth multiplier:(float)infoModel.bad/(float)maxCount constant:0];
        _goodWidConstraint.priority = 50;
        _normalWidConstraint.priority = 50;
        _badWidConstraint.priority = 50;
        
        [_rightView addConstraints:@[_goodWidConstraint,_normalWidConstraint,_badWidConstraint]];

    }
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    
}

- (void)p_removeOldConstraint
{
    [_rightView removeConstraints:@[_goodWidConstraint,_normalWidConstraint,_badWidConstraint]];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

@end
