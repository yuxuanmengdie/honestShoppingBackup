//
//  HSCommodityDetailTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityDetailTableViewCell.h"

@interface HSCommodityDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrait;

@end

@implementation HSCommodityDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setTopEdge:(float)topEdge
{
    if (_topEdge == topEdge) {
        return;
    }
    
    _topEdge = topEdge;
    
    _topConstrait.constant = topEdge;
    
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

@end
