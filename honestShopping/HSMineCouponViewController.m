//
//  HSMineCouponViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineCouponViewController.h"
#import "HSCouponTableViewCell.h"

#import "HSCouponModel.h"

@interface HSMineCouponViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    NSArray *_couponDataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *couponTableView;
@end

@implementation HSMineCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_couponTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCouponTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCouponTableViewCell class])];
    
    _couponTableView.tableFooterView = [[UIView alloc] init];
    _couponTableView.dataSource = self;
    _couponTableView.delegate = self;
    
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
#pragma mark 获取优惠券
- (void)couponRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kGetCouponsByUidURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
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
            NSArray *jsonArr = (NSArray *)json;
            NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    HSCouponModel *couponModel = [[HSCouponModel alloc] initWithDictionary:obj error:nil];
                    [tmpArr addObject:couponModel];
                }
                
            }];
            
            _couponDataArray = tmpArr;

        }
        else
        {
            
        }
        
        [_couponTableView reloadData];
    }];

}

#pragma mark -
#pragma mark tableView dataSource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = _couponDataArray.count;
    
    if (num == 0 && !self.isRequestLoading) {
        [self placeViewWithImgName:nil text:@"还没有任何优惠券"];
    }
    else
    {
        [self removePlaceView];
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCouponTableViewCell class]) forIndexPath:indexPath];
    HSCouponModel *model = _couponDataArray[indexPath.row];
    [cell setUpWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
