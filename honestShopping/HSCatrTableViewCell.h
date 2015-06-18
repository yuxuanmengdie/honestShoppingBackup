//
//  HSCatrTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-5.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKYStepper.h"

typedef void(^HSCartSelectBlock)(void);

@interface HSCatrTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;

@property (weak, nonatomic) IBOutlet UILabel *titlelabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet PKYStepper *stepper;

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (copy, nonatomic) HSCartSelectBlock selectBlock;

@end
