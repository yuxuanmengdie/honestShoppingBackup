//
//  HSAddressModel.h
//  honestShopping
//
//  Created by 张国俗 on 15-5-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "JSONModel.h"

/// 地址信息
@interface HSAddressModel : JSONModel

@property (copy, nonatomic) NSString *id;

@property (copy, nonatomic) NSString *uid;

@property (copy, nonatomic) NSString *consignee;

@property (copy, nonatomic) NSString *address;

@property (copy, nonatomic) NSString *mobile;

@property (copy, nonatomic) NSString *sheng;

@property (copy, nonatomic) NSString *shi;

@property (copy, nonatomic) NSString *qu;

@property (copy, nonatomic) NSString *is_default;

@end

/*

 
 [{"id":"9","uid":"143","consignee":"sunjian","address":"12312312","mobile":"13916077449","sheng":"\u6c5f\u82cf\u7701","shi":"\u5357\u4eac\u5e02","qu":"\u7384\u6b66\u533a"},{"id":"10","uid":"143","consignee":"sunjian","address":"sssss","mobile":"13916077449","sheng":"\u6c5f\u82cf\u7701","shi":"\u5357\u4eac\u5e02","qu":"\u7384\u6b66\u533a"}]


*/