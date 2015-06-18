//
//  HSEditAddressTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSAddressDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *leftTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftTitleWidthConstraint;
@end
