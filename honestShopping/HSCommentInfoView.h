//
//  HSCommentInfoView.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HSCommentInfoModel;

@interface HSCommentInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodLabel;

@property (weak, nonatomic) IBOutlet UILabel *normalLabel;

@property (weak, nonatomic) IBOutlet UILabel *badLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *normalCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *badCountLabel;

/**
 *  填充数据
 *
 *  @param infoModel 评论的info
 */
- (void)setUpWithInfoModel:(HSCommentInfoModel *)infoModel;



@end
