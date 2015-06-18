//
//  HSCouponTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCouponTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation HSCouponTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithModel:(HSCouponModel *)couponModle
{
    [_couponImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kCoupImageHeaderURL,couponModle.img]] placeholderImage:kPlaceholderImage];
    
    _validDateLabel.text = @"有效期至：";//[HSPublic controlNullString:couponModle.endtime];
    _dateLabel.text = [HSPublic controlNullString:[HSPublic dateFormatterWithTimeIntervalSince1970:[couponModle.endtime doubleValue] formatter:@"YYYY-MM-dd"]];//[HSPublic controlNullString:couponModle.starttime];
    _introLabel.text = [HSPublic controlNullString:couponModle.desc];
    _explainLabel.text = [HSPublic controlNullString:couponModle.name];
}

@end
