//
//  HSSubmitOrderAddressTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSAddressModel.h"

@interface HSSubmitOrderAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

/// 用于没有地址时提示文字的显示
@property (weak, nonatomic) IBOutlet UILabel *tipLable;

- (void)setUpWithModel:(HSAddressModel *)addressModel;

- (void)setupWithUserName:(NSString *)username phone:(NSString *)phone address:(NSString *)address;
@end
