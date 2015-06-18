//
//  HSCommodityItemDetailPicModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-24.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

@interface HSCommodityItemDetailPicModel : JSONModel

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *cate_id;
@property (copy, nonatomic) NSString *orig_id;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *intro;
@property (copy, nonatomic) NSString *img;
@property (copy, nonatomic) NSString *price;
@property (copy, nonatomic) NSString *rates;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *comments;
@property (copy, nonatomic) NSString *cmt_taobao_time;
@property (copy, nonatomic) NSString *add_time;
@property (copy, nonatomic) NSString *ordid;
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *info;
@property (strong, nonatomic) NSArray *tuwen; ///详细内容都是图片
@property (copy, nonatomic) NSString *news;
@property (copy, nonatomic) NSString *tuijian;
@property (copy, nonatomic) NSString *goods_stock;
@property (copy, nonatomic) NSString *buy_num;
@property (copy, nonatomic) NSString *brand;
@property (copy, nonatomic) NSString *pingyou;
@property (copy, nonatomic) NSString *kuaidi;
@property (copy, nonatomic) NSString *ems;
@property (copy, nonatomic) NSString *free;
@property (copy, nonatomic) NSString *color;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *maxbuy;
@property (copy, nonatomic) NSString *ischeck;
@property (copy, nonatomic) NSString *standard;
@property (copy, nonatomic) NSString *tuan;
@property (copy, nonatomic) NSString *tuan_price;
@property (copy, nonatomic) NSString *tuan_time;
@property (copy, nonatomic) NSString *maill_price;
@property (copy, nonatomic) NSString *ordernum;
@property (copy, nonatomic) NSString *likes;
@property (strong, nonatomic) NSArray *banner; // 顶部的轮播图


@end

/*
 {
 "add_time" = 0;
 "board_id" = 1;
 clicks = 0;
 content = "1503/27/5514c5054542b.jpg";
 desc = 390;
 "end_time" = 1448899200;
 extimg = "";
 extval = "";
 id = 16;
 name = "\U7eff\U73e0";
 ordid = 3;
 "start_time" = 1417363200;
 status = 1;
 type = image;
 url = "http://ecommerce.news.cn/index.php?m=Item&a=index&cid=363&id=390";
 },
 
 */
