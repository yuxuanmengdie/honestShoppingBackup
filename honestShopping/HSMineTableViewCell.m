//
//  HSMineTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-5.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineTableViewCell.h"

@implementation HSMineTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _mainTitleLaabel.textColor = kAPPTintColor;
    _rightLabel.textColor = kAPPTintColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
