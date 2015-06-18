//
//  HSBannerModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-3-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

/// 轮播图
@interface HSBannerModel : JSONModel

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *board_id;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *extimg;
@property (copy, nonatomic) NSString *extval;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *start_time;
@property (copy, nonatomic) NSString *end_time;
@property (copy, nonatomic) NSString *clicks;
@property (copy, nonatomic) NSString *add_time;
@property (copy, nonatomic) NSString *ordid;
@property (copy, nonatomic) NSString *status;
/*
@property (copy, nonatomic) NSString *
@property (copy, nonatomic) NSString *
@property (copy, nonatomic) NSString *
*/
@end

/*

 "id":"9",
 "board_id":"1",
 "type":"image",
 "name":"\u7a3b\u82b1\u9999",
 "url":"http:\/\/203.192.7.23\/index.php?m=Book&a=cate&cid=363",
 "content":"1410\/20\/5444ea0c104f0.jpg",
 "extimg":"",
 "extval":"",
 "desc":"",
 "start_time":"1413561600",
 "end_time":"1421510400",
 "clicks":"0",
 "add_time":"0",
 "ordid":"4",
 "status":"1"

*/