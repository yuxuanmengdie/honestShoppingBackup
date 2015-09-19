//
//  HSCommentListModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"
#import "HSCommentItemModel.h"

@protocol HSCommentItemModel
@end

// 商品评论model
@interface HSCommentListModel : JSONModel

@property (nonatomic, assign) int currentPage;

@property (nonatomic, assign) int totalPage;

@property (nonatomic, copy) NSString *total;

@property (nonatomic, strong) NSArray <HSCommentItemModel>* comment_list;

@end

/*

 "currentPage":1,
 "totalPage":1,
 "total":"10",
 "comment_list":[]
 */