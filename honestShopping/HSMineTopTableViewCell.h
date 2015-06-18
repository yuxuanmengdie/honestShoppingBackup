//
//  HSMineTopTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HSMineTopTableViewCellSignBlock)(void);

@interface HSMineTopTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImgView;

@property (weak, nonatomic) IBOutlet UIButton *signButton;

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (copy, nonatomic) HSMineTopTableViewCellSignBlock signBlock;

/// 签到
- (void)signStatus:(BOOL)isSign;

/// 欢迎语
- (void)welcomeText:(NSString *)text isLogin:(BOOL)isLogin;
@end
