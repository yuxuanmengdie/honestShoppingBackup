//
//  HSPayTypeTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 0 是支付宝 1 是微信
typedef void(^HSPayTypeBlock)(int type);

/// 选择支付方式的cell
@interface HSPayTypeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;

@property (weak, nonatomic) IBOutlet UIButton *aliPayButton;

@property (weak, nonatomic) IBOutlet UIButton *weixinPayButton;

@property (copy, nonatomic) HSPayTypeBlock payTypeBlock;

@end
