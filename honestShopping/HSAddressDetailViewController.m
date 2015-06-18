//
//  HSAddressDetailViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSAddressDetailViewController.h"
#import "HSEditAddressViewController.h"

#import "HSAddressDetailTableViewCell.h"
#import "UIView+HSLayout.h"

@interface HSAddressDetailViewController ()<UITableViewDelegate,
UITableViewDataSource>
{
    UIButton *_confirmButton;
    
    /// 标题数组
    NSArray *_detailDataArray;
    /// 具体信息数组
    NSArray *_contentDataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *addressDetailTableView;

@end

@implementation HSAddressDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    
    [self setNavBarRightBarWithTitle:@"修改" action:@selector(updateAddress)];
    
    _detailDataArray = @[@"收货人",@"手机号码",@"所在地区",@"详细地址"];
    [self contentDataInitWithAddressModel:_addressModel];
    [_addressDetailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSAddressDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSAddressDetailTableViewCell class])];
    _addressDetailTableView.dataSource = self;
    _addressDetailTableView.delegate = self;
    
    if (![_addressModel.is_default isEqualToString:@"1"]) { /// 不是默认地址
        [self footerView];
    }
    
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

- (void)footerView
{
    UIView *footerView = [[UIView alloc] init];
    CGRect rect = _addressDetailTableView.bounds;
    rect.size.height = 100;
    footerView.frame = rect;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton = button;
    button.contentEdgeInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    [button setTitle:@"设置为默认收货地址" forState:UIControlStateNormal];
    [button setBackgroundImage:[HSPublic ImageWithColor:kAPPTintColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5.0;
    [button addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:button];
    [footerView HS_centerXYWithSubView:button];
    [footerView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:16]];
    
    _addressDetailTableView.tableFooterView = footerView;
    
}

#pragma mark -
#pragma mark 修改默认地址的响应
- (void)confirmAction
{
    [self defaultAddressRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode] add_id:[HSPublic controlNullString:_addressModel.id]];
}

#pragma mark -
#pragma mark 地址内容信息 构造成数组
- (void)contentDataInitWithAddressModel:(HSAddressModel *)model
{
    _contentDataArray = @[[HSPublic controlNullString:model.consignee],[HSPublic controlNullString:model.mobile],[NSString stringWithFormat:@"%@%@%@",[HSPublic controlNullString:model.sheng],[HSPublic controlNullString:model.shi],[HSPublic controlNullString:model.qu]],[HSPublic controlNullString:model.address]];
}

#pragma mark -
#pragma mark 修改地址
- (void)updateAddress
{
    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSEditAddressViewController *detailVC = [stroyboard instantiateViewControllerWithIdentifier:NSStringFromClass([HSEditAddressViewController class])];
    detailVC.addressModel = _addressModel;
    detailVC.userInfoModel = _userInfoModel;
    detailVC.addressChangeType = HSeditaddressByUpdateType;
    detailVC.title = @"修改地址";
    [self.navigationController pushViewController:detailVC animated:YES];
    
    __weak typeof(self) wself = self;
    detailVC.updateBlcok = ^(HSAddressModel *addModel){
        __strong typeof(wself) swself = wself;
        swself.addressModel = addModel;
        [swself contentDataInitWithAddressModel:addModel];
        [swself->_addressDetailTableView reloadData];
    };

}

#pragma mark - 
#pragma mark 删除地址
- (void)deldelAddressRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode add_id:(NSString *)add_id
{
    [self showhudLoadingInWindowWithText:@"删除..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonAddId:add_id,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kDelAddressURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"删除失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmp = (NSDictionary *)json;
            
           NSNumber *status = tmp[kPostJsonStatus];
            
            if (status != nil && [status boolValue]) {
                [self showHudWithText:@"删除成功"];
                [self backAction:nil];
            }
            else
            {
                [self showHudWithText:@"删除失败"];
            }
            
        }
        else
        {
            
        }
    }];

}

#pragma mark - 设置为默认地址 {"uid":143,"add_id":10,"sessionCode":"10EEF472-09FE-1B20-900C-E6E4322FF855","key":"f528764d624db129b32c21fbca0cb8d6"}
- (void)defaultAddressRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode add_id:(NSString *)add_id
{
    [self showhudLoadingInWindowWithText:@"设置中..." isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonAddId:add_id,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kSetDefaultAddressURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"设置失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmp = (NSDictionary *)json;
            
            BOOL status = [tmp[kPostJsonStatus] boolValue];
            
            if (status) {
                [self showHudWithText:@"设置成功"];
                _addressModel.is_default = @"1"; /// 设置成默认的
                _addressDetailTableView.tableFooterView = [[UIView alloc] init]; /// 去掉footerView
            }
            else 
            {
                [self showHudWithText:@"设置失败"];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (section == 0) {
        num = 4;
    }
    else
    {
        num = 1;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSAddressDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSAddressDetailTableViewCell class]) forIndexPath:indexPath];
//    cell.separatorInset = UIEdgeInsetsZero;
    cell.leftTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if (indexPath.section == 1) {
        cell.leftTitleWidthConstraint.constant = 300;
        cell.leftTitleLabel.text = @"删除收货地址";
        cell.leftTitleLabel.textColor = [UIColor redColor];
        cell.contentLabel.text = @"";
    }
    else
    {
        cell.leftTitleWidthConstraint.constant = 70;
        cell.leftTitleLabel.text = _detailDataArray[indexPath.row];
        cell.leftTitleLabel.textColor = [UIColor darkGrayColor];
        cell.contentLabel.text = _contentDataArray[indexPath.row];
    }
    
    return cell;
}

-(void)viewDidLayoutSubviews
{
    if ([self.addressDetailTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.addressDetailTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.addressDetailTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.addressDetailTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) { /// 删除地址
        [self deldelAddressRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode] add_id:[HSPublic controlNullString:_addressModel.id]];
    }
}


@end
