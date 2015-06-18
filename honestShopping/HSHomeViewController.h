//
//  HSHomeViewController.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-29.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "HSCommodtyItemModel.h"

typedef void(^HSHomeCollectionCellSelectedBlock)(HSCommodtyItemModel *itemModel);
/// 首页中第一个页面
@interface HSHomeViewController : HSBaseViewController


@property (nonatomic, copy) HSHomeCollectionCellSelectedBlock cellSelectedBlock;
@end
