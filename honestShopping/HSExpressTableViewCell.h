//
//  HSExpressTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-12-28.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HSExpressProgressView;

@interface HSExpressTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HSExpressProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *expressTitle;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;

- (void)lastedStatus:(BOOL)isLasted;

@end
