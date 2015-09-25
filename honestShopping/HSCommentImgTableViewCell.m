//
//  HSCommentImgTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommentImgTableViewCell.h"
#import "HCSStarRatingView.h"
#import "HSCommentItemModel.h"
#import "UIImageView+WebCache.h"

@implementation HSCommentImgTableViewCell

static const float kCellOriHei = 50;

static const float kVerSpacing = 8;

static const int kMaxCountInline = 3;

static const float KHorSpacing = 20;

static const int kImgViewOriTag = 800;

- (void)awakeFromNib {
    // Initialization code
    _starsView.tintColor = kAppYellowColor;
    _userNameLabel.textColor = [UIColor grayColor];
    _timeLabel.textColor = [UIColor lightGrayColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithItemModel:(HSCommentItemModel *)itemModel;
{
    _userNameLabel.text = [HSPublic controlNullString:itemModel.uname];
    _timeLabel.text = [HSPublic controlNullString:[HSPublic dateFormWithTimeDou:[itemModel.add_time doubleValue]]];
    _starsView.value = [itemModel.star floatValue];
}

- (void)addSubImgViewsWithList:(NSArray *)list
{
    //清楚历史的imgview 防止多次重叠
    for (UIView *sub in self.contentView.subviews) {
        if ([sub isMemberOfClass:[UIImageView class]]) {
            [sub removeFromSuperview];
        }
    }
    
    if (list.count == 0) {
        return;
    }
    [self.contentView layoutIfNeeded];
    float totalWid = CGRectGetWidth(self.contentView.bounds);
    float wid = (totalWid - (kMaxCountInline + 1)*KHorSpacing)/(CGFloat)kMaxCountInline;
    
    [list enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        UIImageView *imgview = [UIImageView new];
        imgview.userInteractionEnabled = YES;
        NSString *fullPath = [NSString stringWithFormat:@"%@%@",kCommentImageHeaderURL,obj];
        [imgview sd_setImageWithURL:[NSURL URLWithString:fullPath] placeholderImage:kPlaceholderImage];
        [self.contentView addSubview:imgview];
        imgview.tag = kImgViewOriTag + idx;
        imgview.translatesAutoresizingMaskIntoConstraints = NO;
        
        [imgview addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:wid]];
        [imgview addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:wid]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewAction:)];
        [imgview addGestureRecognizer:tap];
        
    }];
    
    UIImageView *firstImg = (UIImageView *)[self.contentView viewWithTag:kImgViewOriTag];
    // 关闭username 的autosizing  属性
    _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 第一个imgview 的leading和top 约束
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:firstImg attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:KHorSpacing]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:firstImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_userNameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kVerSpacing]];
    
    int line = 0;
    for (int j=1; j<list.count; j++) {
        
        UIView *lastView = [self.contentView viewWithTag:kImgViewOriTag+j-1];
        UIView *currentImg = [self.contentView viewWithTag:kImgViewOriTag+j];
        
        // 能整除， 左边就是contentView
        if (j%kMaxCountInline == 0) {
            // 每一行第一个imgview 与firstImg 左对齐
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:currentImg attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:firstImg attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
            // 自己顶部的view
            UIView *topView = [self.contentView viewWithTag:kImgViewOriTag+(line-1)*kMaxCountInline];
            // 每一行第一个 与上一行的第一个 竖直方向的约束
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:currentImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kVerSpacing]];
        }
        else
        {
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:currentImg attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:KHorSpacing]];
            
            // 在同一行 top对齐
            if (j/kMaxCountInline == line) {
                
                UIView *lineFirstView = [self.contentView viewWithTag:kImgViewOriTag+line*kMaxCountInline];
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:currentImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lineFirstView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            }

        }
        
        // line记录下次换行
        if ((j+1)%kMaxCountInline == 0) {
            line++;
        }
    }
}

- (void)imgViewAction:(UITapGestureRecognizer *)tap
{
    UIImageView *imgView = (UIImageView *)tap.view;
    
    NSUInteger idx = imgView.tag - kImgViewOriTag;
    
    if (self.imgActionBlock) {
        self.imgActionBlock(idx,imgView);
    }
}

+ (CGFloat)cellHeightWithImgCount:(NSUInteger)count cellWidth:(CGFloat)wid
{
    CGFloat hei = kCellOriHei;
    
    if (count > 0) {
        
        NSUInteger num = ((count - 1) / kMaxCountInline)  + 1;
        
        CGFloat verSapcing = (num + 1)*kVerSpacing;
        
        CGFloat itemWidHei = (wid - (kMaxCountInline + 1)*KHorSpacing)/(CGFloat)kMaxCountInline;
        
        // 因为图片是正方形的
        hei += verSapcing + itemWidHei*num;
    }
    
    NSLog(@"%s, hei=%f",__func__,hei);
    return hei;
}

@end
