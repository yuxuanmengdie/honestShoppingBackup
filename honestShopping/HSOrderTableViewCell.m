//
//  HSOrderTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSOrderTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation HSOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _priceLabel.textColor = [UIColor redColor];
    _stateLabel.textColor = kAppYellowColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithModel:(HSOrderModel *)orderModel
{
    [_commodityImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,[HSPublic controlNullString:orderModel.img]]] placeholderImage:kPlaceholderImage];
    
    _orderIDLabel.text = [HSPublic controlNullString:orderModel.orderId];
    _timeLabel.text = [HSPublic controlNullString:[HSPublic dateFormWithTimeDou:[orderModel.add_time doubleValue]]];
    _priceLabel.text = [NSString stringWithFormat:@"￥%@元",[HSPublic controlNullString:orderModel.order_sumPrice] ];
    _stateLabel.text = [HSPublic controlNullString:[HSPublic orderStatusStrWithState:orderModel.status]];

}
@end
