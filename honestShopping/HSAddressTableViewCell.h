//
//  HSAddressTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSAddressModel.h"

@interface HSAddressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

/// 根据是否默认修改字体颜色 以及隐藏imageView
- (void)addressIsDefault:(BOOL)isDefault;

/// 地址类型为HSMineAddressReadType
- (void)setupWithModel:(HSAddressModel *)addressModel;

/// 地址类型为HSMineAddressSelecteType
- (void)dataWithModel:(HSAddressModel *)addressModel selectAddressID:(NSString *)addressID;

@end
