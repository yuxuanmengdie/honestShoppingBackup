//
//  HSFavoriteTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSCommodtyItemModel.h"

typedef void(^HSFavoriteTableViewCellCancelBlcok)(void);

@interface HSFavoriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *commodityImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *introLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (copy, nonatomic) HSFavoriteTableViewCellCancelBlcok cancelBlock;

- (void)setupWirhModel:(HSCommodtyItemModel *)itemModel;

@end
