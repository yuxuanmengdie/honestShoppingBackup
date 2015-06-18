//
//  HSCommodityCategaryCollectionViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSCommodityCategaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *categaryTitleLabel;



/// 是否选择 修改字体颜色和大小
- (void)changeTitleColorAndFont:(BOOL)isSelected;
@end
