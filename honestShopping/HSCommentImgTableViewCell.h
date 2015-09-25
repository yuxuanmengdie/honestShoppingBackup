//
//  HSCommentImgTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSStarRatingView;
@class HSCommentItemModel;

//
typedef void(^HSCommentImgActionBlock)(NSUInteger idx, UIImageView *imgView);

@interface HSCommentImgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet HCSStarRatingView *starsView;

@property (copy, nonatomic) HSCommentImgActionBlock imgActionBlock;

#pragma mark - method
- (void)setUpWithItemModel:(HSCommentItemModel *)itemModel;

// 添加动态的imgview 的数量
- (void)addSubImgViewsWithList:(NSArray *)list;

/**
 *  cell 的高度
 *
 *  @param count img 的数量
 *  @param wid   cell 的宽度
 *
 *  @return 根据数量 返回应有的高度
 */
+ (CGFloat)cellHeightWithImgCount:(NSUInteger)count cellWidth:(CGFloat)wid;

@end
