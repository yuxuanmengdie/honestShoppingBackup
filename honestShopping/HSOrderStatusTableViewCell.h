//
//  HSOrderStatusTableViewCell.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSOrderStatusTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@end
