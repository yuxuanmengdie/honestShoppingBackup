//
//  HSCouponModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-31.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

/// 优惠券 model
@interface HSCouponModel : JSONModel

@property (copy, nonatomic) NSString *id;

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *desc;

@property (copy, nonatomic) NSString *starttime;

@property (copy, nonatomic) NSString *endtime;

@property (copy, nonatomic) NSString *price;

@property (copy, nonatomic) NSString *type;

@property (copy, nonatomic) NSString *time;

@property (copy, nonatomic) NSString *is_del;

@property (copy, nonatomic) NSString *t_price;

@property (copy, nonatomic) NSString *img;

@property (copy, nonatomic) NSString *is_app;

/*
 
 [{"id":"18","name":"app\u9996\u98751","desc":"app","starttime":"1408464000","endtime":"1451491200","price":"5.00","type":"0","time":"1432003169","is_del":"0","t_price":"100.00","img":"1505\/21\/555d9fcf1e5fa.png","is_app":"1"},{"id":"19","name":"app\u9996\u98752","desc":"","starttime":"1408464000","endtime":"1451491200","price":"10.00","type":"0","time":"1432003449","is_del":"0","t_price":"200.00","img":"1505\/21\/555d9fd928aff.png","is_app":"1"},{"id":"21","name":"app\u9996\u98753","desc":"","starttime":"1408464000","endtime":"1451491200","price":"20.00","type":"0","time":"1432003628","is_del":"0","t_price":"300.00","img":"1505\/21\/555d9fe144386.png","is_app":"1"}]
 
 */

@end
