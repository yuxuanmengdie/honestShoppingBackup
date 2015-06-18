//
//  HSCommodityCategaryCollectionViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityCategaryCollectionViewCell.h"

@implementation HSCommodityCategaryCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (void)changeTitleColorAndFont:(BOOL)isSelected
{
 //   [UIView animateWithDuration:1.0 animations:^{
    
        
        if (isSelected) {//选中状态
            _categaryTitleLabel.font = [UIFont systemFontOfSize:16];
            _categaryTitleLabel.textColor = kAPPTintColor;
        }
        else // 没选择
        {
            _categaryTitleLabel.font = [UIFont systemFontOfSize:14];
            _categaryTitleLabel.textColor = kAppYellowColor;
        }

//    }];
}

@end
