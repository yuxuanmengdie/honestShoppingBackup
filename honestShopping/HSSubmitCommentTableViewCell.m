//
//  HSSubmitCommentTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitCommentTableViewCell.h"

@implementation HSSubmitCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _photoImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPhoto)];
    [_photoImgView addGestureRecognizer:tapGes];
    
    [_submitBtn setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    _textView.delegate = self;
    _textView.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)submitAction:(id)sender {
    
    if (self.callBackBlock) {
        self.callBackBlock(1);
    }
}

- (void)selectPhoto
{
    if (self.callBackBlock) {
        self.callBackBlock(0);
    }

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutIfNeeded];
    
    CGFloat hei = CGRectGetHeight(_submitBtn.frame);
    _submitBtn.layer.masksToBounds = YES;
    _submitBtn.layer.cornerRadius = hei/2.0f;
}

#pragma textview delegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textChangedBlock) {
        self.textChangedBlock(textView.text);
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
