//
//  HSMineTopTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineTopTableViewCell.h"

@implementation HSMineTopTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _signButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
    [_signButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    [_signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _signButton.layer.masksToBounds = YES;
    _signButton.layer.cornerRadius = 5.0;
    
    _welcomeLabel.textColor = kAPPTintColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)signAction:(id)sender {
    if (self.signBlock) {
        self.signBlock();
    }
}


- (void)signStatus:(BOOL)isSign
{
    NSString *text = isSign ? @"已签到" : @"签到";
    
    [_signButton setTitle:text forState:UIControlStateNormal];
    
    _signButton.enabled = YES; /// 已经签到后，按钮失效
    if (isSign) {
        _signButton.enabled = NO;
    }
}

- (void)welcomeText:(NSString *)text isLogin:(BOOL)isLogin
{
    if (!isLogin) { /// 未登录
        _welcomeLabel.text = @"您好，请先登录！";
    }
    else
    {
        NSString *tmp = text.length > 0 ? text : @"";
        _welcomeLabel.text = [NSString stringWithFormat:@"您好，%@",tmp];
    }
}
@end
