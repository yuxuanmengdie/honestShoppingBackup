//
//  HSSubmitCommentStarTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

typedef void(^HSSubmitCommentStarChangedBlcok)(float value);

@interface HSSubmitCommentStarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HCSStarRatingView *starRatingView;

@property (copy, nonatomic) HSSubmitCommentStarChangedBlcok changedBlcok;

@end
