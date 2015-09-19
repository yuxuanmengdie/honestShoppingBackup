//
//  HSCommentItemModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"
/**
 *  单个评论model
 */
@interface HSCommentItemModel : JSONModel

@property (nonatomic, copy) NSString *id;

@property (nonatomic, copy) NSString *item_id;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *uname;

@property (nonatomic, copy) NSString *info;

@property (nonatomic, copy) NSString *add_time;

@property (nonatomic, copy) NSString *star;

@property (nonatomic, copy) NSString *com_id;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *ordid;

@property (nonatomic, copy) NSString *status;

@end

/*

 "id":"54",
 "item_id":"404",
 "uid":"137",
 "uname":"test",
 "info":"\u8fd9\u662f\u6d4b\u8bd5\u6570\u636e",
 "add_time":null,
 "star":"3",
 "com_id":null,
 "url":null,
 "ordid":null,
 "status":null
*/