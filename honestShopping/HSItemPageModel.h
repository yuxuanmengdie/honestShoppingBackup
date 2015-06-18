//
//  HSItemPageModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"
#import "HSCommodtyItemModel.h"

@protocol HSCommodtyItemModel <NSObject>


@end

@interface HSItemPageModel : JSONModel

@property (strong, nonatomic) NSNumber *currentPage;
@property (strong, nonatomic) NSNumber *totalPage;
@property (strong, nonatomic) NSNumber *total;
@property (strong, nonatomic) NSArray <HSCommodtyItemModel>*item_list;

@end

/*

 "currentPage":1,
 "totalPage":33,
 "total":"66",
 "item_list":[


*/