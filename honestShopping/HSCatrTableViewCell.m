//
//  HSCatrTableViewCell.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-5.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCatrTableViewCell.h"

@implementation HSCatrTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _stepper.stepInterval = 1.0;
    _stepper.minimum = 1.0;
    _stepper.value = 1.0;
//    __weak typeof(_stepper) weakStepper = _stepper;
//    [_stepper setValueChangedCallback:^(PKYStepper *stepper, float newValue){
//        weakStepper.countLabel.text = [NSString stringWithFormat:@"%d",(int)newValue];
//    }];
    [_stepper setButtonWidth:24.0f];
    [_stepper setBorderColor:kAPPTintColor];
    [_stepper setLabelTextColor:kAPPTintColor];
    [_stepper setButtonTextColor:kAPPTintColor forState:UIControlStateNormal];
    [_stepper setup];
    
    [_selectButton setImage:[UIImage imageNamed:@"icon_unselected"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamed:@"icon_selected"] forState:UIControlStateSelected];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectAction:(id)sender {
    
    if (self.selectBlock) {
        self.selectBlock();
    }
}
@end
