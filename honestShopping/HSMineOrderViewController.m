//
//  HSMineOrderViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-25.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineOrderViewController.h"
#import "HSPayOrderViewController.h"
#import "HSSubmitCommentViewController.h"
#import "HSSubmitCommentItemViewController.h"
#import "HSExpressViewController.h"
#import "HSOrderTableViewCell.h"

#import "HSOrderModel.h"

typedef NS_ENUM(NSUInteger, MineOrderStatus) {
    MineOrderAwaitPayStatus = 1,
    MineOrderAwaitShippedStatus = 2,
    MineOrderAwaitReceivingStatus = 3,
    MineOrderSuccessStatus = 4,
    MineOrderClosedStatus = 5
};

@interface HSMineOrderViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    NSArray *_unfinishedDataArray;
    
    NSArray *_finishedDataArray;
    
    BOOL _completeOrderLoading;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UIView *sepView;

@property (weak, nonatomic) IBOutlet UITableView *unfinishedTableView;

@property (weak, nonatomic) IBOutlet UITableView *finishedTableView;

@end

@implementation HSMineOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"我的订单"];
    
    [_unfinishedTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSOrderTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSOrderTableViewCell class])];
    [_finishedTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSOrderTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSOrderTableViewCell class])];
    _unfinishedTableView.dataSource = self;
    _unfinishedTableView.delegate = self;
    _finishedTableView.dataSource = self;
    _finishedTableView.delegate = self;
    
    _unfinishedTableView.tableFooterView = [[UIView alloc] init];
    _finishedTableView.tableFooterView = [[UIView alloc] init];
    
    [self.httpRequestOperationManager.operationQueue addObserver:self
                  forKeyPath:@"operationCount"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    [self segmentSetup];
    
    [self orderRequestWithStatus:MineOrderAwaitPayStatus uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    [self orderRequestWithStatus:MineOrderAwaitShippedStatus uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    [self orderRequestWithStatus:MineOrderAwaitReceivingStatus uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    [self orderRequestWithStatus:MineOrderClosedStatus uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    
    [self showNetLoadingView];
    _completeOrderLoading = NO;
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
- (void)segmentSetup
{
    _segmentControl.tintColor = kAPPTintColor;
    [_segmentControl setTitle:@"未完成" forSegmentAtIndex:0];
    [_segmentControl setTitle:@"已完成" forSegmentAtIndex:1];
}

#pragma mark -
#pragma mark 获取不同状态的订单 1.代付款 2.待发货 3.待收获 4.完成 5。关闭
- (void)orderRequestWithStatus:(int)status uid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    if (status == MineOrderSuccessStatus) { /// 请求一次后不论结果 不在重复请求
        _completeOrderLoading = YES;
    }
    
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonStatus:[NSString stringWithFormat:@"%d",status]
                                    };
    [self.httpRequestOperationManager POST:kGetOrderListURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
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

        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArr = (NSArray *)json;
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                HSOrderModel *model = [[HSOrderModel alloc] initWithDictionary:obj error:nil];
                [tmp addObject:model];
            }];
            
            if (status == MineOrderSuccessStatus) { //完成的
             
                _finishedDataArray = tmp;
                [_finishedTableView reloadData];
            }
            else
            {
                if (_unfinishedDataArray == nil) {
                    _unfinishedDataArray = tmp;
                }
                else
                {
                    NSMutableArray *mArr = [[NSMutableArray alloc] initWithArray:_unfinishedDataArray];
                    [mArr addObjectsFromArray:tmp];
                    _unfinishedDataArray = mArr;

                }
                [_unfinishedTableView reloadData];
            }
        }
        else
        {
            
        }
    }];

}

#pragma mark -
#pragma mark segment action
- (IBAction)segmentAction:(id)sender {
    NSInteger idx = _segmentControl.selectedSegmentIndex;
    
    _unfinishedTableView.hidden = !(idx == 0);
    _finishedTableView.hidden = (idx == 0);
    
    if (idx != 0 && !_completeOrderLoading && _finishedDataArray.count == 0) {
        [self orderRequestWithStatus:MineOrderSuccessStatus uid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
    }
    
}
#pragma mark -
#pragma mark KVO,观察parseQueue是否执行完
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.httpRequestOperationManager.operationQueue && [keyPath isEqualToString:@"operationCount"])
    {
        if (0 == self.httpRequestOperationManager.operationQueue.operationCount)
        {
            [self hiddenMsg];
        }
    }
}

#pragma mark - 
#pragma mark tableView dataSource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = tableView == _unfinishedTableView ? _unfinishedDataArray.count : _finishedDataArray.count;
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _unfinishedTableView) {
        
        HSOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSOrderTableViewCell class]) forIndexPath:indexPath];
        HSOrderModel *model = _unfinishedDataArray[indexPath.row];
        [cell setupWithModel:model];
        return cell;
        
    }
    else
    {
        HSOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSOrderTableViewCell class]) forIndexPath:indexPath];
        HSOrderModel *model = _finishedDataArray[indexPath.row];
        [cell setupWithModel:model];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HSOrderModel *model =  nil;
    
    if (tableView == _unfinishedTableView) {
        model = _unfinishedDataArray[indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSPayOrderViewController *pay = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSPayOrderViewController class])];
        pay.hidesBottomBarWhenPushed = YES;
        pay.title = @"支付订单";
        pay.userInfoModel = _userInfoModel;
        pay.orderID = model.orderId;
        [self.navigationController pushViewController:pay animated:YES];

    }
    else
    {
        model = _finishedDataArray[indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSSubmitCommentItemViewController *submitVC = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSSubmitCommentItemViewController class])];
        submitVC.hidesBottomBarWhenPushed = YES;
        submitVC.title = @"待评价商品";
        submitVC.userInfoModel = _userInfoModel;
        submitVC.orderID = model.orderId;
        [self.navigationController pushViewController:submitVC animated:YES];
       
    }
    
}

#pragma mark -
#pragma mark delloc
- (void)dealloc
{
    [self.httpRequestOperationManager.operationQueue cancelAllOperations];
    [self.httpRequestOperationManager.operationQueue removeObserver:self forKeyPath:@"operationCount"];
    self.httpRequestOperationManager = nil;
    
    NSLog(@"%s",__func__);
}

@end
