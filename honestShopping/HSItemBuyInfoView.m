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
   [_collectButton setTitle:@"转赠他人" forState:UIControlStateNormal];
    
    _collectButton.contentEdgeInsets = UIEdgeInsetsMake(5, 16, 5, 16);
    [_collectButton setBackgroundImage:[HSPublic ImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_collectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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


- (IBAction)collectBtnAction:(id)sender {
    if (self.colletActionBlock) {
        self.colletActionBlock(sender);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutIfNeeded];
    _collectButton.layer.masksToBounds = YES;
    _collectButton.layer.cornerRadius = CGRectGetHeight(_collectButton.frame)/2.0;
    _collectButton.layer.borderColor = kAPPLightGreenColor.CGColor;
    _collectButton.layer.borderWidth = 1.0;
    

}

@end
