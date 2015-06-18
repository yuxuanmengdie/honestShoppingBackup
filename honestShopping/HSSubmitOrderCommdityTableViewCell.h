//
//  HSSubmitOrderCommdityTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSCommodityItemDetailPicModel.h"
#import "HSOrderModel.h"

@interface HSSubmitOrderCommdityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *commdityImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *numLabel;

/// 商品model
- (void)setUpWithModel:(HSCommodityItemDetailPicModel *)detailModel imagePreURl:(NSString *)preURL num:(int)num;


/// 订单中单个的model
- (void)setupWithOrderItemModel:(HSOrderitemModel *)itemModel;
@end
