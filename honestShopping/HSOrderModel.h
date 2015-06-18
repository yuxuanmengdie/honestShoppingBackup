//
//  HSOrderModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

@protocol HSOrderitemModel <NSObject>


@end

@interface HSOrderModel : JSONModel

@property (copy, nonatomic) NSString *id;

@property (copy, nonatomic) NSString *orderId;

@property (copy, nonatomic) NSString *add_time;

@property (copy, nonatomic) NSString *goods_sumPrice;

@property (copy, nonatomic) NSString *order_sumPrice;

@property (copy, nonatomic) NSString *note;

@property (copy, nonatomic) NSString *userId;

@property (copy, nonatomic) NSString *userName;

@property (copy, nonatomic) NSString *address_name;

@property (copy, nonatomic) NSString *mobile;

@property (copy, nonatomic) NSString *address;

@property (copy, nonatomic) NSString *status;

@property (copy, nonatomic) NSString *supportmetho;

@property (copy, nonatomic) NSString *freetype;

@property (copy, nonatomic) NSString *freeprice;

@property (copy, nonatomic) NSString *closemsg;

@property (copy, nonatomic) NSString *support_time;

@property (copy, nonatomic) NSString *sellerRemark;

@property (copy, nonatomic) NSString *userfree;

@property (copy, nonatomic) NSString *freecode;

@property (copy, nonatomic) NSString *fahuoaddress;

@property (copy, nonatomic) NSString *fahuo_time;

@property (copy, nonatomic) NSString *ordertype;

@property (copy, nonatomic) NSString *coupon;

@property (copy, nonatomic) NSString *score;

@property (copy, nonatomic) NSString *img;

/// 订单详细中商品的
@property (strong, nonatomic) NSArray <Optional,HSOrderitemModel>* item_list;

@end

/// 订单详细中商品的model
@interface HSOrderitemModel : JSONModel

@property (copy, nonatomic) NSString *id;

@property (copy, nonatomic) NSString *orderId;

@property (copy, nonatomic) NSString *itemId;

@property (copy, nonatomic) NSString *title;

@property (copy, nonatomic) NSString *img;

@property (copy, nonatomic) NSString *price;

@property (copy, nonatomic) NSString *quantity;

@property (copy, nonatomic) NSString *brand;

@property (copy, nonatomic) NSString *cate_id;

@property (copy, nonatomic) NSString *uid;

@end


/*
 
 [{"id":"781","orderId":"201506011046225464A","add_time":"1433169982","goods_sumPrice":"45.00","order_sumPrice":"57.00","note":null,"userId":"14167","userName":"LOL\u4e86ee","address_name":"","mobile":"18655061482","address":"\u5317\u4eac\u5317\u4eac\u4e1c\u57ce\u533a\u4e94V5rrrr","status":"1","supportmetho":"1","freetype":"1","freeprice":"12.00","closemsg":null,"support_time":null,"sellerRemark":null,"userfree":"","freecode":"","fahuoaddress":null,"fahuo_time":null,"ordertype":"0","coupon":"0","score":"0","img":"1503\/27\/551523a9eedbe.png"}]
 
 
 */
