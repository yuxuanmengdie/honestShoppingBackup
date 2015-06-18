//
//  HSCommodityCollectionViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPLabel.h"
#import "HSCommodtyItemModel.h"

@interface HSCommodityCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet UILabel *titlelabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet LPLabel *oldPricelabel;

/// 设置数据源
- (void)dataSetUpWithModel:(HSCommodtyItemModel *)itemModel;
@end
