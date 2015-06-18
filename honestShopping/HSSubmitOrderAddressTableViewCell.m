//
//  HSSubmitOrderAddressTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitOrderAddressTableViewCell.h"

@implementation HSSubmitOrderAddressTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithModel:(HSAddressModel *)addressModel
{
    if (addressModel == nil) { /// 地址为空
        _userNameLabel.text = @"";
        _phoneLabel.text = @"";
        _detailLabel.text = @"";
        _tipLable.text = @"还没有收货地址，请添加";
        _tipLable.hidden = NO;
    }
    else
    {
        _tipLable.hidden = YES;
        
        _userNameLabel.text = [NSString stringWithFormat:@"收货人：%@",[HSPublic controlNullString:addressModel.consignee]];
        _phoneLabel.text = [HSPublic controlNullString:addressModel.mobile];
        _detailLabel.text = [NSString stringWithFormat:@"收货地址：%@%@%@%@",[HSPublic controlNullString:addressModel.sheng],[HSPublic controlNullString:addressModel.shi],[HSPublic controlNullString:addressModel.qu],[HSPublic controlNullString:addressModel.address]];
    }
}

- (void)setupWithUserName:(NSString *)username phone:(NSString *)phone address:(NSString *)address
{
    _tipLable.hidden = YES;
    
    _userNameLabel.text = [NSString stringWithFormat:@"收货人：%@",[HSPublic controlNullString:username]];
    _phoneLabel.text = [HSPublic controlNullString:phone];
    _detailLabel.text = [NSString stringWithFormat:@"收货地址：%@",[HSPublic controlNullString:address]];
}

@end
