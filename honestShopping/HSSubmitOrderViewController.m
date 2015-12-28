//
//  HSSubmitOrderViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-6-1.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitOrderViewController.h"
#import "HSMineAddressViewController.h"
#import "HSPayOrderViewController.h"

#import "HSSubmitOrderAddressTableViewCell.h"
#import "HSSubmitOrderCommdityTableViewCell.h"
#import "UIView+HSLayout.h"
#import "HSCouponSelectedView.h"

#import "HSCommodityItemDetailPicModel.h"
#import "HSAddressModel.h"
#import "HSCouponModel.h"

@interface HSSubmitOrderViewController ()<UITableViewDelegate,
UITableViewDataSource>
{
    NSArray *_commdityDataArray; /// 包含商品的列表
    
    HSSubmitOrderAddressTableViewCell *_placeAddressCell;
    
    HSAddressModel *_addressModel;
    
    /// 选择优惠券的底部视图
    UIView *_couponBgView;
    /// 优惠券 选择视图
    HSCouponSelectedView *_couponView;
    
    NSArray *_couponDataArray;
    /// 需要上传的优惠券ID 的model
    HSCouponModel *_couponModel;
    /// 邮费
    NSString *_postageprice;
    
    AFHTTPRequestOperationManager *_postageRequestOperation;
}
@property (weak, nonatomic) IBOutlet UITableView *submitOrdertableView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *bottomSepView;

@property (weak, nonatomic) IBOutlet UILabel *prePriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *_totalPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation HSSubmitOrderViewController

static NSString *const kCouponTableViewIdentifier = @"hsCouponTableViewIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _commdityDataArray = _itemsDataArray;
    [_submitOrdertableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderAddressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class])];
    [_submitOrdertableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class])];
    [_submitOrdertableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    _submitOrdertableView.dataSource = self;
    _submitOrdertableView.delegate = self;
    
    [self getDefaultAddressWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    [self bottomViewSetup];
    [self couponRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 
#pragma mark bottomView的状态
- (void)bottomViewSetup
{
    _prePriceLabel.textColor = kAPPTintColor;
    self._totalPriceLabel.textColor = [UIColor redColor];
    float postPrice = 0.0;
    if ([HSPublic isAreaInJiangZheHu:_addressModel.sheng])
    {
        postPrice = 0.0;
    }
    else
    {
        postPrice = 12.0;
    }

    self._totalPriceLabel.text = [NSString stringWithFormat:@"%0.2f元",[self totolMoneyWithoutPostage]+postPrice];

    [_submitButton setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitButton setTitle:@"确认订单" forState:UIControlStateNormal];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 5.0;
}


- (IBAction)submitAction:(id)sender {
    
    if (_addressModel == nil) { // 未选择地址
        [self showHudWithText:@"请选择地址"];
        return;
    }
    
    NSString *free = [HSPublic isAreaInJiangZheHu:_addressModel.sheng] ? @"0" : @"1";
    [self addOrderWithUid:[HSPublic controlNullString:_userInfoModel.id] couponId:[HSPublic controlNullString:_couponModel.id] username:[HSPublic controlNullString:_addressModel.consignee] addressName:@"" mobile:[HSPublic controlNullString:_addressModel.mobile] address:[NSString stringWithFormat:@"%@%@%@%@",[HSPublic controlNullString:_addressModel.sheng],[HSPublic controlNullString:_addressModel.shi],[HSPublic controlNullString:_addressModel.qu],[HSPublic controlNullString:_addressModel.address]]supportmethod:@"1" freetype:free sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode] list:[self listOrder]];
    
}

#pragma mark - 
#pragma mark 选择优惠券view
- (void)p_showCouponSelectedView
{
    if (_couponBgView == nil) {
        _couponBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _couponBgView.backgroundColor = [UIColor blackColor];
        _couponBgView.alpha = 0.6;
        _couponBgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_couponBgView];
        [self.view HS_edgeFillWithSubView:_couponBgView];
        
        _couponBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapAction)];
        [_couponBgView addGestureRecognizer:tap];
    }
    
    if (_couponView == nil) {
        _couponView = [[HSCouponSelectedView alloc] initWithFrame:CGRectZero];
        _couponView.backgroundColor = [UIColor whiteColor];
        _couponView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_couponView.couponTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCouponTableViewIdentifier];
        _couponView.couponTableView.dataSource = self;
        _couponView.couponTableView.delegate = self;
        [self.view addSubview:_couponView];
        [self.view HS_centerXYWithSubView:_couponView];
        [self.view HS_dispacingWithFisrtView:_couponView fistatt:NSLayoutAttributeLeading secondView:self.view secondAtt:NSLayoutAttributeLeading constant:20];
        
        _couponView.layer.masksToBounds = YES;
        _couponView.layer.cornerRadius = 5.0;
        
    }
    
    _couponBgView.hidden = NO;
    _couponView.hidden = NO;
    
    __weak typeof(self) wself = self;
    _couponView.verifyBlock = ^(NSString *text){
        __strong typeof(wself) swself = wself;
        if (text.length == 0) {
            [swself showHudWithText:@"不能为空"];
            return ;
        }
        
        [swself getCouponIdByCouponNoWithUid:[HSPublic controlNullString:swself.userInfoModel.id] sessionCode:[HSPublic controlNullString:swself.userInfoModel.sessionCode] couponNo:text];
    };
    [_couponView.couponTableView reloadData];
}

- (void)bgTapAction
{
    _couponBgView.hidden = YES;
    _couponView.hidden = YES;
    [_couponView.couponTextField resignFirstResponder];
}
#pragma mark - 
#pragma mark 根据优惠券编号 获取ID
- (void)getCouponIdByCouponNoWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode couponNo:(NSString *)couponNo
{
    [self showhudLoadingWithText:@"验证中..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonCouponNo:couponNo
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetCouponIdByCouponNoURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
       [self hiddenHudLoading];
        if (operation.responseData == nil) {
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }

        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDic = (NSDictionary *)json;
            
            NSNumber *status = jsonDic[kPostJsonStatus];
            if (status != nil) {
                [self showHudWithText:@"优惠券编码有误"];
            }
            else
            {
                NSString *cou_ID = jsonDic[@"cou_id"];
                NSString *price = jsonDic[@"price"];
                NSString *name = jsonDic[@"name"];
                _couponModel = [[HSCouponModel alloc] init];
                _couponModel.price = price;
                _couponModel.id = cou_ID;
                _couponModel.name = name;
                [self p_reloadWithAddressModel:_addressModel];
            }
        }
        else
        {
            
        }
    }];

}

#pragma mark -
#pragma mark 获取优惠券
- (void)couponRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kGetCouponsByUidURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            [self couponRequestWithUid:uid sessionCode:sessionCode];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }        
        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArr = (NSArray *)json;
            NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    HSCouponModel *couponModel = [[HSCouponModel alloc] initWithDictionary:obj error:nil];
                    [tmpArr addObject:couponModel];
                }
                
            }];
            
            _couponDataArray = [tmpArr copy];
            if (_couponView == nil || (_couponView != nil && _couponView.hidden)) {
                [self p_showCouponSelectedView];
                [self bgTapAction];
            }
            
            _couponView.tableViewHeight = 44*_couponDataArray.count;
            [_couponView.couponTableView reloadData];
            
        }
        else
        {
            
        }
        
        [_couponView.couponTableView reloadData];
    }];
    
}



#pragma mark -
#pragma mark 获取默认地址
- (void)getDefaultAddressWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetDefaultAddressURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenMsg];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenMsg];
        if (operation.responseData == nil) {
            [self showReqeustFailedMsg];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }

        
        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *tmpArr = (NSArray *)json;
            [tmpArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                HSAddressModel *model = [[HSAddressModel alloc] initWithDictionary:obj error:nil];
                if (model.id.length > 0) {
                    _addressModel = model;
                    
                    [self p_reloadWithAddressModel:model];
                    //[_submitOrdertableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    NSString *freeType = [HSPublic isAreaInJiangZheHu:model.sheng] ? @"0" : @"1";
                    [self getFreePriceRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] num:[NSString stringWithFormat:@"%d",[self totalNum]] freetype:freeType sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
                
                }
                
                if (idx == 0) {
                    *stop = YES;
                }

            }];
            }
        else
        {
           
        }
    }];

}


#pragma mark -
#pragma mark 获取商品的总数
- (int)totalNum
{
    __block int num = 0;
    
    [_itemNumDic.allValues enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        num += [obj intValue];
    }];
    
    return num;
}

#pragma mark -
#pragma mark 获取总价格 不包含邮费
- (float)totolMoneyWithoutPostage
{
    __block float total = 0.0;
    [_commdityDataArray enumerateObjectsUsingBlock:^(HSCommodityItemDetailPicModel *obj, NSUInteger idx, BOOL *stop) {
        
        NSString *cid = [HSPublic controlNullString:obj.id];
        NSNumber *num = _itemNumDic[cid];
        int count = [num intValue] < 0 ? 0 : [num intValue];
        float price = [obj.price floatValue] < 0 ? 0: [obj.price floatValue];
        
        total += count * price;
        
    }];
    return total;
}

#pragma mark -
#pragma mark 重新请求
- (void)reloadRequestData
{
    [super reloadRequestData];
     [self getDefaultAddressWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
}

#pragma mark -
#pragma mark 获取邮费
- (void)getFreePriceRequestWithUid:(NSString *)uid num:(NSString *)num freetype:(NSString *)freetype sessionCode:(NSString *)sessionCode
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonNum:num,
                                    kPostJsonFreetype:freetype
                                    };
    // 142346261  123456
    if (_postageRequestOperation == nil) {
        _postageRequestOperation = [[AFHTTPRequestOperationManager alloc] init];
    }
    [_postageRequestOperation POST:kGetFreePriceURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            [self getFreePriceRequestWithUid:uid num:num freetype:freetype sessionCode:sessionCode];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }
        
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDic = (NSDictionary *)json;
            NSNumber *price = jsonDic[kPostJsonFreeprice];
            if (price != nil) {
                _postageprice = [NSString stringWithFormat:@"%0.2f",[price floatValue]];
//                [_submitOrdertableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_commdityDataArray.count + 1 inSection:1],[NSIndexPath indexPathForRow:_commdityDataArray.count + 2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
//                self._totalPriceLabel.text = [NSString stringWithFormat:@"应付金额：%0.2f",[self totolMoneyWithoutPostage] + [price floatValue]];
                [self p_reloadWithAddressModel:_addressModel];

            }
            }
        else
        {
            
        }
    }];

}

#pragma mark -
#pragma mark 根据商品数组组织订单的上传字段
- (NSArray *)listOrder
{
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:_commdityDataArray.count];
    
    [_commdityDataArray enumerateObjectsUsingBlock:^(HSCommodityItemDetailPicModel *obj, NSUInteger idx, BOOL *stop) {
        NSString *itemId = obj.id;
        
        NSString *cid = [HSPublic controlNullString:obj.id];
        NSNumber *num = _itemNumDic[cid];
        int count = [num intValue] < 0 ? 0 : [num intValue];
        
        NSDictionary *dic = @{kPostJsonItemid:[HSPublic controlNullString:itemId],
                              kPostJsonQuantity:[NSNumber numberWithInt:count]};
        [tmp addObject:dic];
        
    }];
    
    return tmp;
}
#pragma mark -
#pragma mark push到支付订单页面
- (void)pushToOrderPayVC:(NSString *)orderID
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSPayOrderViewController *pay = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSPayOrderViewController class])];
    pay.hidesBottomBarWhenPushed = YES;
    pay.title = @"支付订单";
    pay.userInfoModel = _userInfoModel;
    pay.orderID = orderID;
    [self.navigationController pushViewController:pay animated:YES];
}


#pragma mark -
#pragma mark 确认订单
/*
 {"uid":143,"couponId":205,"username":"ssss","addressName":"aaaa","mobile":13916077449,"address":"dddd","supportmethod":1,"freetype":1,"list":[{"itemId":155,"quantity":1},{"itemId":156,"quantity":2}],"sessionCode":"10EEF472-09FE-1B20-900C-E6E4322FF855","key":"f528764d624db129b32c21fbca0cb8d6"}
 */
- (void)addOrderWithUid:(NSString *)uid couponId:(NSString *)couponId username:(NSString *)username addressName:(NSString *)addressName mobile:(NSString *)mobile address:(NSString *)address supportmethod:(NSString *)supportmethod freetype:(NSString *)freetype sessionCode:(NSString *)sessionCode list:(NSArray *)list
{
    [self showhudLoadingInWindowWithText:@"提交订单..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonCouponId:couponId,
                                    kPostJsonUserName:username,
                                    kPostJsonAddressName:addressName,
                                    kPostJsonMobile:mobile,
                                    kPostJsonAddress:address,
                                    kPostJsonSupportmethod:supportmethod,
                                    kPostJsonFreetype:freetype,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonList:list,
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kAddOrderURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }

        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            NSString *orderNo = tmpDic[kPostJsonOrderNo];
            if (orderNo.length > 0) {
                [self showHudWithText:@"订单提交成功"];
                [self pushToOrderPayVC:orderNo];
                
            }
            
        }
        else
        {
            
        }
    }];

}



#pragma mark -
#pragma mark tableView dataSource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _couponView.couponTableView) {
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _couponView.couponTableView) {
        return _couponDataArray.count;
    }

    
    NSInteger num = 0;
    if (section == 0) {
        num = 1;
    }
    else // 商品种类 + 优惠券 + 运费 + 总计
    {
        num = _commdityDataArray.count + 3;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /// 优惠券
    if (tableView == _couponView.couponTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCouponTableViewIdentifier forIndexPath:indexPath];
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }

        UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:601];
        if (textLabel == nil) {
            textLabel = [[UILabel alloc] init];
            textLabel.font = [UIFont systemFontOfSize:14];
            textLabel.tag = 601;
            textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:textLabel];
            [cell.contentView HS_dispacingWithFisrtView:textLabel fistatt:NSLayoutAttributeLeading secondView:cell.contentView secondAtt:NSLayoutAttributeLeading constant:8];
            [cell.contentView HS_centerYWithSubView:textLabel];
        }
       
        HSCouponModel *couponModel = _couponDataArray[indexPath.row];
        textLabel.text = [HSPublic controlNullString:couponModel.name];
         NSLog(@"%@",[HSPublic controlNullString:couponModel.name]);
        return cell;
    }

    
    /// 订单的tableview
    if (indexPath.section == 0) { /// 地址
        HSSubmitOrderAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class]) forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setUpWithModel:_addressModel];
        return cell;
    }
    else
    {
        if (indexPath.row < _commdityDataArray.count) { /// 商品详情
            HSSubmitOrderCommdityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) forIndexPath:indexPath];
            HSCommodityItemDetailPicModel *detailModel = _commdityDataArray[indexPath.row];
            int num = [_itemNumDic[[HSPublic controlNullString:detailModel.id]] intValue];
            [cell setUpWithModel:detailModel imagePreURl:kImageHeaderURL num:num];
            
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
            for (UIView *subView in cell.contentView.subviews) {
                [subView removeFromSuperview];
            }
            if (indexPath.row == _commdityDataArray.count) { // 优惠券
                 UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:501];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:502];
                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 501;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeLeading secondView:leftLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 502;
                    rightLabel.textAlignment = NSTextAlignmentRight;
                    rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:leftLabel fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [rightLabel setContentCompressionResistancePriority:240 forAxis:UILayoutConstraintAxisHorizontal];
                    [rightLabel setContentHuggingPriority:240 forAxis:UILayoutConstraintAxisHorizontal];
                }

                leftLabel.text = @"优惠券：";
                rightLabel.text = [HSPublic controlNullString:_couponModel.name];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (indexPath.row == _commdityDataArray.count + 1) // 运费
            {
                UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:503];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:504];
                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 503;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeLeading secondView:leftLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 504;
                    rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];

                }
                leftLabel.text = @"运费：";
                if (_postageprice.length == 0) {
                     rightLabel.text = @"江浙沪包邮，其他省市12元";
                }
                else if ([HSPublic isAreaInJiangZheHu:_addressModel.sheng])
                {
                    rightLabel.text = @"江浙沪包邮";
                }
                else
                {
                    rightLabel.text = [NSString stringWithFormat:@"%@元",_postageprice];
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else // 合计
            {
                UILabel *leftLabel = (UILabel *)[cell.contentView viewWithTag:505];
                UILabel *rightLabel = (UILabel *)[cell.contentView viewWithTag:506];
                if (rightLabel == nil) {
                    rightLabel = [[UILabel alloc] init];
                    rightLabel.tag = 505;
                    //rightLabel.textColor = kAppYellowColor;
                    rightLabel.font = [UIFont systemFontOfSize:14];
                    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:rightLabel];
                    [cell.contentView HS_dispacingWithFisrtView:cell.contentView fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeTrailing constant:8];
                    [cell.contentView HS_centerYWithSubView:rightLabel];
                    
                }

                if (leftLabel == nil) {
                    leftLabel = [[UILabel alloc] init];
                    leftLabel.tag = 506;
                    leftLabel.font = [UIFont systemFontOfSize:14];
                    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [cell.contentView addSubview:leftLabel];
                    [cell.contentView HS_dispacingWithFisrtView:leftLabel fistatt:NSLayoutAttributeTrailing secondView:rightLabel secondAtt:NSLayoutAttributeLeading constant:-8];
                    [cell.contentView HS_centerYWithSubView:leftLabel];
                    
                }
                int num = [self totalNum]; // 商品总数
                float postPrice = 0.0;
                if ([HSPublic isAreaInJiangZheHu:_addressModel.sheng])
                {
                    postPrice = 0.0;
                }
                else
                {
                    postPrice = _postageprice.length > 0 ? [_postageprice floatValue] : 12;
                }

                float price = [self totolMoneyWithoutPostage] + postPrice - [_couponModel.price floatValue];
                NSString *str1 = @"共有";
                NSString *str2 = @"件商品";
                NSString *str3 = @"合计:";
                NSString *leftStr = [NSString stringWithFormat:@"%@%d%@",str1,num,str2];
                NSString *rightStr = [NSString stringWithFormat:@"%@￥%0.2f",str3,price];
                
                NSMutableAttributedString *left = [[NSMutableAttributedString alloc] initWithString:leftStr];
                NSMutableAttributedString *right = [[NSMutableAttributedString alloc] initWithString:rightStr];
                
                [left addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, str1.length)];
                [left addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:NSMakeRange(str1.length, leftStr.length-str2.length-str1.length)];
                [left addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(leftStr.length-str2.length,str2.length)];
                
                [right addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0,str3.length)];
                [right addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14.0] range:NSMakeRange(str3.length,right.length-str3.length)];
                leftLabel.attributedText = left;
                rightLabel.attributedText = right;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _couponView.couponTableView) {
        return 44;
    }

    CGFloat height = 0.0;
    
    if (indexPath.section == 0) {
        
        if (_placeAddressCell == nil) {
            _placeAddressCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderAddressTableViewCell class])];
            _placeAddressCell.bounds = tableView.bounds;
            _placeAddressCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [_placeAddressCell setNeedsLayout];
        }
        NSLog(@"cell hei %f", _placeAddressCell.detailLabel.frame.size.width);
        [_placeAddressCell setUpWithModel:_addressModel];
        _placeAddressCell.detailLabel.preferredMaxLayoutWidth = _placeAddressCell.detailLabel.frame.size.width;
        [_placeAddressCell.contentView updateConstraintsIfNeeded];
        [_placeAddressCell.contentView layoutIfNeeded];
        height = [_placeAddressCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0;
    }
    else
    {
        if (indexPath.row < _commdityDataArray.count) {
            height = 80;
        }
        else
        {
            height = 44;
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _couponView.couponTableView) {
        
        HSCouponModel *model = _couponDataArray[indexPath.row];
        [self bgTapAction];
        if ([model.t_price floatValue] > [self totolMoneyWithoutPostage]) { /// 不满足条件
            [self showHudWithText:@"商品金额不满足使用条件"];
            return;
        }
        _couponModel = model;
        
        //[_submitOrdertableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_commdityDataArray.count inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self p_reloadWithAddressModel:_addressModel];
        return;
    }
    
    
    if (indexPath.section == 0) {
        
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSMineAddressViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineAddressViewController class])];
        vc.userInfoModel = _userInfoModel;
        vc.addressType = HSMineAddressSelecteType;
        vc.addressID = _addressModel.id;
        vc.title = @"选择收货地址";
        [self.navigationController pushViewController:vc animated:YES];
       
        __weak typeof(self) wself = self;
        vc.selectBlock = ^(HSAddressModel *addModel){
            __strong typeof(wself) swself = wself;
            [swself->_postageRequestOperation.operationQueue cancelAllOperations]; /// 取消上次的邮费请求
            
            swself->_addressModel = addModel;
            [swself p_reloadWithAddressModel:addModel];
            
            NSString *freeType = [HSPublic isAreaInJiangZheHu:addModel.sheng] ? @"0" : @"1";
            [swself getFreePriceRequestWithUid:[HSPublic controlNullString:swself.userInfoModel.id] num:[NSString stringWithFormat:@"%d",[swself totalNum]] freetype:freeType sessionCode:[HSPublic controlNullString:swself.userInfoModel.sessionCode]];
            };
    }
    else if (indexPath.section == 1 && indexPath.row == _commdityDataArray.count) // 优惠券
    {
        [self p_showCouponSelectedView];
    }
}

#pragma mark -
#pragma mark 根据address信息刷新界面
- (void)p_reloadWithAddressModel:(HSAddressModel *)addModel
{
    float postPrice = 0.0;
    if ([HSPublic isAreaInJiangZheHu:addModel.sheng])
    {
        postPrice = 0.0;
    }
    else
    {
        //postPrice = 12.0;
         postPrice = _postageprice.length > 0 ? [_postageprice floatValue] : 12;
    }
    self._totalPriceLabel.text = [NSString stringWithFormat:@"%0.2f元",[self totolMoneyWithoutPostage]+postPrice -[_couponModel.price floatValue]];
     [_submitOrdertableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:_commdityDataArray.count inSection:1],[NSIndexPath indexPathForRow:_commdityDataArray.count+1 inSection:1],[NSIndexPath indexPathForRow:_commdityDataArray.count+2 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    

}

- (void)dealloc
{
     [self.httpRequestOperationManager.operationQueue cancelAllOperations];
     [_postageRequestOperation.operationQueue cancelAllOperations];
}
@end
