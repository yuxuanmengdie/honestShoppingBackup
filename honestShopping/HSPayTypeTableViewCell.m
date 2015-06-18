//
//  HSPayTypeTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSPayTypeTableViewCell.h"

@implementation HSPayTypeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [_aliPayButton setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];
    [_aliPayButton setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
    
    [_weixinPayButton setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];
    [_weixinPayButton setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
    _aliPayButton.selected = YES;
    _weixinPayButton.selected = NO;
    
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)weixinPayAction:(id)sender {
    if (_weixinPayButton.selected) {
        return;
    }
    
    _weixinPayButton.selected = YES;
    _aliPayButton.selected = NO;
    
    if (self.payTypeBlock) {
        self.payTypeBlock(1);
    }
}

- (IBAction)aliPayAction:(id)sender {
    if (_aliPayButton.selected) {
        return;
    }

    _aliPayButton.selected = YES;
    _weixinPayButton.selected = NO;
    
    if (self.payTypeBlock) {
        self.payTypeBlock(0);
    }

}

@end
