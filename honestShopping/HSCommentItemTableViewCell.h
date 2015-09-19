//
//  HSCommentItemTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-17.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSStarRatingView;
@class HSCommentItemModel;

@interface HSCommentItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *starsView;

- (void)setUpWithItemModel:(HSCommentItemModel *)itemModel;

@end
