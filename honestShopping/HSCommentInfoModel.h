//
//  HSCommentInfoModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

// 评论中整体信息
@interface HSCommentInfoModel : JSONModel

@property (nonatomic, assign) int good;

@property (nonatomic, assign) int normal;

@property (nonatomic, assign) int bad;

@property (nonatomic, assign) int total;

@property (nonatomic, assign) int percent;

@end

/*
 {"good":7,"normal":1,"bad":2,"total":"10","percent":70}
*/