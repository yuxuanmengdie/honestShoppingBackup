//
//  HSSubmitCommentItemViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitCommentItemViewController.h"
#import "HSSubmitCommentViewController.h"

#import "HSSubmitOrderCommdityTableViewCell.h"
#import "HSOrderModel.h"

@interface HSSubmitCommentItemViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
     NSArray *_dataArray;
    
    HSOrderModel *_orderModel;
}


@property (nonatomic, strong) UITableView *submitTableView;

@end

@implementation HSSubmitCommentItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.submitTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class])];

    [self getOrderDetailRequest:[HSPublic controlNullString:_userInfoModel.id] orderID:[HSPublic controlNullString:_orderID] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - subViews commitInit
- (UITableView *)submitTableView
{
    if (_submitTableView == nil) {
        
        _submitTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _submitTableView.backgroundColor = ColorRGB(244, 244, 244);
        [self.view addSubview:_submitTableView];
        _submitTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _submitTableView.dataSource = self;
        _submitTableView.delegate = self;
        _submitTableView.tableFooterView = [UIView new];
        
        if ([_submitTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_submitTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_submitTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_submitTableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        id top = self.topLayoutGuide;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top][_submitTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top,_submitTableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_submitTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_submitTableView)]];
        
    }
    
    return _submitTableView;
}

#pragma mark - 网络请求
#pragma mark - 获取订单详情
- (void)getOrderDetailRequest:(NSString *)uid orderID:(NSString *)orderID sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonOrderId:orderID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetOrderDetailURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
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
        
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            HSOrderModel *orderModel = [[HSOrderModel alloc] initWithDictionary:tmpDic error:nil];
            if (orderModel.id.length > 0) {
                _orderModel = orderModel;
                _dataArray = _orderModel.item_list;
                
                [_submitTableView reloadData];
            }
        }
        else
        {
            
        }
    }];
    
}

#pragma mark - tableview dataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HSSubmitOrderCommdityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) forIndexPath:indexPath];
   
    HSOrderitemModel *itemlModel = _dataArray[indexPath.row];
    [cell setupWithOrderItemModel:itemlModel];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;

}

// 去除左边分隔符15 像素
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

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
    CGFloat hei = 80;
    
    return hei;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HSOrderitemModel *itemlModel = _dataArray[indexPath.row];
    
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSSubmitCommentViewController *submitVC = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSSubmitCommentViewController class])];
    submitVC.hidesBottomBarWhenPushed = YES;
    submitVC.title = @"待评价商品";
    submitVC.userInfoModel = _userInfoModel;
    submitVC.orderID = _orderModel.orderId;
    submitVC.dataArray = @[itemlModel];
    submitVC.orderModel = _orderModel;
    [self.navigationController pushViewController:submitVC animated:YES];
   
}

@end
