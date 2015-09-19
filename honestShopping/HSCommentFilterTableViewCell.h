//
//  HSCommentFilterTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-18.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

// 响应block 0 开始
typedef void(^HSCommentFilterActionBlock)(int idx);

/**
 *  筛选商品评论的cell
 */
@interface HSCommentFilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *totalCommentsBtn;

@property (weak, nonatomic) IBOutlet UIButton *imgCommentsBtn;

@property (copy, nonatomic) HSCommentFilterActionBlock filterBlock;

@end
