//
//  HSAdItemModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-7.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

@interface HSAdItemModel : JSONModel
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *content;

@end

/*

 "name":"\u71d5\u9ea6\u7247",
 "desc":"383",
 "content":"1503\/26\/55136dc9b0391.jpg"

*/