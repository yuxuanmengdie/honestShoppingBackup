//
//  HSCommodityCollectionViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityCollectionViewCell.h"

@implementation HSCommodityCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;
    self.layer.borderColor = kAPPTintColor.CGColor;
    self.layer.borderWidth = 0.5;

}


- (void)dataSetUpWithModel:(HSCommodtyItemModel *)itemModel
{
    _titlelabel.text = [NSString stringWithFormat:@"%@ %@",[HSPublic controlNullString:itemModel.title],[HSPublic controlNullString:itemModel.standard]];
    
    _priceLabel.text = [NSString stringWithFormat:@"%@元",[HSPublic controlNullString:itemModel.price]];
    _priceLabel.textColor = [UIColor redColor];
    _oldPricelabel.text = [HSPublic controlNullString:nil];
    _oldPricelabel.textColor = [UIColor grayColor];
    _oldPricelabel.strikeThroughEnabled = YES;
    _oldPricelabel.strikeThroughColor = _oldPricelabel.textColor;
}


@end
