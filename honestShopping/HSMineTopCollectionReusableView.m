//
//  HSMineTopCollectionReusableView.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineTopCollectionReusableView.h"

@implementation HSMineTopCollectionReusableView

- (void)awakeFromNib {
    // Initialization code
    _signButton.contentEdgeInsets = UIEdgeInsetsMake(5, 16, 5, 16);
    [_signButton setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    [_signButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _signButton.layer.masksToBounds = YES;
    _signButton.layer.cornerRadius = 5.0;
    
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = 40;
    _headerImageView.layer.borderWidth = 1.0;
    _headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;

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
        _userNameLabel.text = @"您好，请先登录！";
    }
    else
    {
        NSString *tmp = text.length > 0 ? text : @"";
        _userNameLabel.text = [NSString stringWithFormat:@"您好，%@",tmp];
    }
}



- (IBAction)signAction:(id)sender {
    if (self.signBlock) {
        self.signBlock();
    }
    
}
@end
