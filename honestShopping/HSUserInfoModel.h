//
//  HSUserInfoModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-4-30.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"
/// 用户信息model
@interface HSUserInfoModel : JSONModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *byear;
@property (nonatomic, copy) NSString *bmonth;
@property (nonatomic, copy) NSString *bday;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *score;
@property (nonatomic, copy) NSString *score_level;
@property (nonatomic, copy) NSString *sessionCode;
@property (nonatomic, assign) BOOL sign;
@property (nonatomic, copy) NSString *is_vip;

@end
