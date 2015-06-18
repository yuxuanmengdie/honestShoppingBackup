//
//  HSOrderTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSOrderModel.h"

/// 订单的cell
@interface HSOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;

@property (weak, nonatomic) IBOutlet UILabel *orderIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

- (void)setupWithModel:(HSOrderModel *)orderModel;

@end
