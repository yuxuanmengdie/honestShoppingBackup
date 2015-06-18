//
//  HSCouponTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSCouponModel.h"

@interface HSCouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *couponImageView;

@property (weak, nonatomic) IBOutlet UILabel *validDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@property (weak, nonatomic) IBOutlet UILabel *explainLabel;

- (void)setUpWithModel:(HSCouponModel *)couponModle;


@end
