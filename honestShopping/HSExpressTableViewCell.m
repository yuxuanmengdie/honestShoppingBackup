//
//  HSExpressTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-12-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSExpressTableViewCell.h"
#import "HSExpressProgressView.h"

@implementation HSExpressTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)lastedStatus:(BOOL)isLasted {
    
    if (isLasted) {
        _leadingConstraint.constant = 0;
        _trailingConstraint.constant = 0;
        _expressTitle.textColor = kAPPLightGreenColor;
        _timeLabel.textColor = kAPPLightGreenColor;
        
    } else {
        _leadingConstraint.constant = 16 + 20 + 8;
        _trailingConstraint.constant = 8.0;
        _expressTitle.textColor = [UIColor lightGrayColor];
        _timeLabel.textColor = [UIColor lightGrayColor];
    }
    [_progressView lastedExpressStatus:isLasted];
    [_sepView layoutIfNeeded];
}

@end
