//
//  HSSubmitCommentTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"

// 0是点击img 选择photo 1 为 提交
typedef void(^HSSubmitCommentCallbackBlock)(int idx);

typedef void(^HSSubmitCommentTextChangedBlcok)(NSString *str);
// 订单提交评论
@interface HSSubmitCommentTableViewCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet SZTextView *textView;

@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (copy, nonatomic) HSSubmitCommentCallbackBlock callBackBlock;

@property (copy, nonatomic) HSSubmitCommentTextChangedBlcok textChangedBlock;

@end
