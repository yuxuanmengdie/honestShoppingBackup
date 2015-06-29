//
//  HSCommodityDetailViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-31.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HSCommodtyItemModel.h"
#import "HSItemBuyInfoView.h"

@interface HSCommodityDetailViewController : HSBaseViewController

@property (nonatomic, strong) HSCommodtyItemModel *itemModel;

@property (nonatomic, assign) HSSanpinCategoryType sanpinType;

@end
