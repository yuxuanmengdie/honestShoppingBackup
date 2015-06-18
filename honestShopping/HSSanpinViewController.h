//
//  HSSanpinViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSCommodtyItemModel.h"

typedef void(^HSSanpinCollectionCellSelectedBlock)(HSCommodtyItemModel *itemModel);

@interface HSSanpinViewController : HSBaseViewController

/// 点击单个cell的block
@property (nonatomic, copy) HSSanpinCollectionCellSelectedBlock cellSelectedBlock;

@end
