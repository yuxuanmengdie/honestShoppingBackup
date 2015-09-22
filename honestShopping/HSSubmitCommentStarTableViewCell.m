//
//  HSSubmitCommentStarTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitCommentStarTableViewCell.h"

@implementation HSSubmitCommentStarTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    _starRatingView.tintColor = kAppYellowColor;
    _starRatingView.value = 5;
    _starRatingView.minimumValue = 1;
    _starRatingView.continuous = YES;
    [_starRatingView addTarget:self action:@selector(starChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)starChanged
{
    if (self.changedBlcok) {
        self.changedBlcok(_starRatingView.value);
    }
}

@end
