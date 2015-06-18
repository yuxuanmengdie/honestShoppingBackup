//
//  HSAddressTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSAddressTableViewCell.h"

@implementation HSAddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addressIsDefault:(BOOL)isDefault
{
    if (isDefault) {
        _nickNameLabel.textColor = [UIColor whiteColor];
        _phoneLabel.textColor = [UIColor whiteColor];
        _detailLabel.textColor = [UIColor whiteColor];
        _defaultImageView.hidden = NO;
        self.contentView.backgroundColor = kAPPTintColor;
        _detailLabel.text = [NSString stringWithFormat:@"[默认]%@", [HSPublic controlNullString:_detailLabel.text]];
    }
    else
    {
        _nickNameLabel.textColor = [UIColor blackColor];
        _phoneLabel.textColor = [UIColor blackColor];
        _detailLabel.textColor = [UIColor blackColor];
        _defaultImageView.hidden = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];

    }
}

- (void)setupWithModel:(HSAddressModel *)addressModel
{
    _nickNameLabel.text = [HSPublic controlNullString:addressModel.consignee];
    _phoneLabel.text = [HSPublic controlNullString:addressModel.mobile];
    _detailLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[HSPublic controlNullString:addressModel.sheng],[HSPublic controlNullString:addressModel.shi],[HSPublic controlNullString:addressModel.qu],[HSPublic controlNullString:addressModel.address]];
    BOOL isDefault = [addressModel.is_default isEqualToString:@"1"];
    [self addressIsDefault:isDefault];
    
}

- (void)dataWithModel:(HSAddressModel *)addressModel selectAddressID:(NSString *)addressID
{
    BOOL isEqual = [addressModel.id isEqualToString:addressID];
    [self setupWithModel:addressModel];
    
    _nickNameLabel.textColor = [UIColor blackColor];
    _phoneLabel.textColor = [UIColor blackColor];
    _detailLabel.textColor = [UIColor blackColor];
    _defaultImageView.hidden = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    if (isEqual) {
        _defaultImageView.hidden = NO;
    }
    
}

@end
