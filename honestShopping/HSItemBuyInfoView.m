//
//  HSItemBuyInfoView.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-24.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSItemBuyInfoView.h"

@implementation HSItemBuyInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
   [_collectButton setTitle:@"加入购物车" forState:UIControlStateNormal];
    
    _collectButton.contentEdgeInsets = UIEdgeInsetsMake(5, 16, 5, 16);
    _collectButton.layer.masksToBounds = YES;
    _collectButton.layer.cornerRadius = 5.0;
    [_collectButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    _priceLabel.textColor = ColorRGB(207, 0, 0);

}

- (void)collcetStatus:(BOOL)isCollected
{
    NSString *str = isCollected ? @"已在购物车":@"加入购物车";
    [_collectButton setTitle:str forState:UIControlStateNormal];
    _collectButton.enabled = !isCollected;
    
}

- (void)setupWithItemModel:(HSCommodityItemDetailPicModel *)detailModel
{
    _titleLabel.text = [NSString stringWithFormat:@"%@ %@\n%@",detailModel.title,detailModel.standard,[HSPublic controlNullString:detailModel.intro]];
    _priceLabel.text = [NSString stringWithFormat:@"￥%@",detailModel.price];
}

//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    
//    if (self) {
//        
////        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
////        
////        [self addSubview:subView];
////        subView.backgroundColor = [UIColor clearColor];
////        subView.translatesAutoresizingMaskIntoConstraints = NO;
////        
////        NSString *vfl1 = @"H:|[subView]|";
////        NSString *vfl2 = @"V:|[subView]|";
////        NSDictionary *dic = NSDictionaryOfVariableBindings(subView);
////        
////        NSArray *con1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
////        NSArray *con2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
////        [self addConstraints:con1];
////        [self addConstraints:con2];
//        
//    }
//    
//    return self;
//
//}
//
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    
//    if (self) {
//        
////        UIView *subView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
////        
////        [self addSubview:subView];
////        subView.backgroundColor = [UIColor clearColor];
////        subView.translatesAutoresizingMaskIntoConstraints = NO;
////        
////        NSString *vfl1 = @"H:|[subView]|";
////        NSString *vfl2 = @"V:|[subView]|";
////        NSDictionary *dic = NSDictionaryOfVariableBindings(subView);
////        
////        NSArray *con1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
////        NSArray *con2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
////        [self addConstraints:con1];
////        [self addConstraints:con2];
//
//    }
//    
//    return self;
//}

- (IBAction)collectBtnAction:(id)sender {
    if (self.colletActionBlock) {
        self.colletActionBlock(sender);
    }
}


//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//}
@end
