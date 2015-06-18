//
//  HSSearchResultModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-2.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"
#import "HSCommodtyItemModel.h"

@protocol HSCommodtyItemModel <NSObject>



@end

@interface HSSearchResultModel : JSONModel

@property (strong, nonatomic) NSNumber *currentPage;

@property (strong, nonatomic) NSNumber *totalPage;

@property (copy, nonatomic) NSString *total;

@property (strong, nonatomic) NSArray <HSCommodtyItemModel>*item_list;

@end
