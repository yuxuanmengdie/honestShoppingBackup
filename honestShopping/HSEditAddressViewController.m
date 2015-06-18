//
//  HSEditAddressViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSEditAddressViewController.h"
#import "HSEditAddressContainerTableViewController.h"

@interface HSEditAddressViewController ()
{
    HSEditAddressContainerTableViewController *_containerVC;
}

@end

@implementation HSEditAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavBarRightBarWithTitle:@"保存" action:@selector(saveAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"editAddressContanter"]) {
        _containerVC = segue.destinationViewController;
        
        if (_addressChangeType == HSeditaddressByUpdateType) { /// 更新的
            _containerVC.addressModel = _addressModel;
        }
    }
}

#pragma mark - 
#pragma mark 保存item的响应
- (void)saveAction
{
    if (![self addressInfoIsMacth]) {
        return;
    }

    if (_addressChangeType == HSeditaddressByAddType) { // 新增地址
        
        [self addAddressRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode] consignee:[HSPublic controlNullString:_containerVC.userNameTextFiled.text] address:[HSPublic controlNullString:_containerVC.detailAddressTextView.text] mobile:[HSPublic controlNullString:_containerVC.phoneTextFiled.text] sheng:[HSPublic controlNullString:_containerVC.sheng] shi:[HSPublic controlNullString:_containerVC.shi] qu:[HSPublic controlNullString:_containerVC.qu]];
    }
    else /// 修改地址
    {
        [self updateAddressRequestWithUid:[HSPublic controlNullString:_addressModel.uid] add_id:[HSPublic controlNullString:_addressModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode] consignee:[HSPublic controlNullString:_containerVC.userNameTextFiled.text] address:[HSPublic controlNullString:_containerVC.detailAddressTextView.text] mobile:[HSPublic controlNullString:_containerVC.phoneTextFiled.text] sheng:[HSPublic controlNullString:_containerVC.sheng] shi:[HSPublic controlNullString:_containerVC.shi] qu:[HSPublic controlNullString:_containerVC.qu]];
    }
}

#pragma mark -
#pragma mark 保存新增地址
- (void)addAddressRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode consignee:(NSString *)consignee address:(NSString *)address mobile:(NSString *)mobile sheng:(NSString *)sheng shi:(NSString *)shi qu:(NSString *)qu
{
    [self showhudLoadingWithText:@"保存中..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonConsignee:consignee,
                                    kPostJsonAddress:address,
                                    kPostJsonMobile:mobile,
                                    kPostJsonSheng:sheng,
                                    kPostJsonShi:shi,
                                    kPostJsonQu:qu
                                    };
    [self.httpRequestOperationManager POST:kAddressUpdateURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"保存失败"];
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
            NSDictionary *tmp = (NSDictionary *)json;
            
            BOOL status = [tmp[kPostJsonStatus] boolValue];
            
            if (status) {
                [self showHudWithText:@"保存成功"];
                [self backAction:nil];
            }
            else
            {
                [self showHudWithText:@"保存失败"];
            }
        }
        else
        {
            
        }
    }];

}


#pragma mark -
#pragma mark 更新地址
- (void)updateAddressRequestWithUid:(NSString *)uid add_id:(NSString *)add_id sessionCode:(NSString *)sessionCode consignee:(NSString *)consignee address:(NSString *)address mobile:(NSString *)mobile sheng:(NSString *)sheng shi:(NSString *)shi qu:(NSString *)qu
{
    [self showhudLoadingInWindowWithText:@"保存中..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonid:add_id,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonConsignee:consignee,
                                    kPostJsonAddress:address,
                                    kPostJsonMobile:mobile,
                                    kPostJsonSheng:sheng,
                                    kPostJsonShi:shi,
                                    kPostJsonQu:qu
                                    };
    [self.httpRequestOperationManager POST:kAddressUpdateURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"保存失败"];
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
            NSDictionary *tmp = (NSDictionary *)json;
            
            BOOL status = [tmp[kPostJsonStatus] boolValue];
            
            if (status) {
                [self showHudWithText:@"保存成功"];
                
                HSAddressModel *model = [_addressModel copy];//[[HSAddressModel alloc] init];
                model.uid = uid;
                model.id = add_id;
                model.consignee = consignee;
                model.mobile = mobile;
                model.sheng = sheng;
                model.shi = shi;
                model.qu = qu;
                model.address = address;
               
                if (self.updateBlcok) {
                    self.updateBlcok(model);
                }
                
                [self backAction:nil];
            }
            else
            {
                [self showHudWithText:@"保存失败"];
            }

        }
        else
        {
            
        }
    }];

}


- (BOOL)addressInfoIsMacth
{
    if (_containerVC.userNameTextFiled.text.length == 0) {
        [self showHudWithText:@"用户名为空"];
        return NO;
    }
    
    if (_containerVC.userNameTextFiled.text.length > 20) {
        [self showHudWithText:@"用户名过长"];
        return NO;
    }
    
    if (![HSPublic isPhoneNumberRegex:_containerVC.phoneTextFiled.text ]) {
        [self showHudWithText:@"手机号码格式不符"];
        return NO;
    }
    
    if ([_containerVC.addressLabel.text isEqualToString:_containerVC.addressPlaceHolder]) {
        [self showHudWithText:@"请选择地区"];
        return NO;
    }
    
    if ([_containerVC.detailAddressTextView.text isEqualToString:_containerVC.detailPlaceHolder])
    {
        [self showHudWithText:@"详细地址不能为空"];
        return NO;
    }
    
    if (_containerVC.detailAddressTextView.text.length < 5 || _containerVC.detailAddressTextView.text.length > 60) {
        [self showHudWithText:@"详细地址字数应在5-60之间"];
        return NO;
    }
    
    return YES;
}

@end
