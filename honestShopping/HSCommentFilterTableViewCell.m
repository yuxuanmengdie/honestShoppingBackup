//
//  HSCommentFilterTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-18.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommentFilterTableViewCell.h"

@implementation HSCommentFilterTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [_totalCommentsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_imgCommentsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage *selectedImg  = [HSPublic ImageWithFrame:CGRectMake(0, 0, 16, 16) OutArcColor:[UIColor lightGrayColor] linewidth:1.0 innerArcColor:kAPPLightGreenColor raduis:5];
    UIImage *unSelectedImg = [HSPublic ImageWithFrame:CGRectMake(0, 0, 16, 16) OutArcColor:[UIColor lightGrayColor] linewidth:1.0 innerArcColor:kAPPLightGreenColor raduis:0];
    [_totalCommentsBtn setTitle:@"查看全部评论" forState:UIControlStateNormal];
    [_imgCommentsBtn setTitle:@"看图" forState:UIControlStateNormal];
    [_totalCommentsBtn setImage:selectedImg forState:UIControlStateSelected];
    [_totalCommentsBtn setImage:unSelectedImg forState:UIControlStateNormal];
    [_imgCommentsBtn setImage:selectedImg forState:UIControlStateSelected];
    [_imgCommentsBtn setImage:unSelectedImg forState:UIControlStateNormal];
    
    _totalCommentsBtn.selected = YES;
    _imgCommentsBtn.selected = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - target action
- (IBAction)totalCommentsAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (btn.selected) {
        return;
    }
    
    btn.selected = !btn.selected;
    _imgCommentsBtn.selected = !_imgCommentsBtn.selected;
    
    if (self.filterBlock) {
        self.filterBlock(0);
    }
}

- (IBAction)imgCommentsAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (btn.selected) {
        return;
    }
    
    btn.selected = !btn.selected;
    _totalCommentsBtn.selected = !_totalCommentsBtn.selected;
    
    if (self.filterBlock) {
        self.filterBlock(1);
    }

}
@end
