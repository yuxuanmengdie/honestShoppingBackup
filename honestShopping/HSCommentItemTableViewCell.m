//
//  HSCommentItemTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommentItemTableViewCell.h"
#import "HCSStarRatingView.h"
#import "HSCommentItemModel.h"

@implementation HSCommentItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _starsView.tintColor = kAppYellowColor;
    _userNameLabel.textColor = kAPPLightGreenColor;
    _timeLabel.textColor = kAPPLightGreenColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithItemModel:(HSCommentItemModel *)itemModel;
{
    _userNameLabel.text = [HSPublic controlNullString:itemModel.uname];
    _contentLabel.text = [HSPublic controlNullString:itemModel.info];
    _timeLabel.text = [HSPublic controlNullString:itemModel.add_time];
    _starsView.value = [itemModel.star floatValue];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    _contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(_contentLabel.frame);
}
@end
