//
//  HSMineFavoriteViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineFavoriteViewController.h"
#import "HSCommodityDetailViewController.h"

#import "HSFavoriteTableViewCell.h"
#import "HSCommodtyItemModel.h"
#import "HSDBManager.h"

@interface HSMineFavoriteViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    NSArray *_favoriteDataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *favoriteTableView;

@end

@implementation HSMineFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_favoriteTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSFavoriteTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSFavoriteTableViewCell class])];
    
    _favoriteTableView.tableFooterView = [[UIView alloc] init];
    _favoriteTableView.dataSource = self;
    _favoriteTableView.delegate = self;

    [self favoriteRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];

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
#pragma mark 获取我的收藏 关注
- (void)favoriteRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kGetFavoriteURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
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
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            NSMutableArray *dbArr = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [HSDBManager deleteAllWithTableName:[HSDBManager tableNameFavoriteWithUid]];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    HSCommodtyItemModel *itemModel = [[HSCommodtyItemModel alloc] initWithDictionary:obj error:nil];
                    [tmp addObject:itemModel];
                    if (itemModel.id.length > 0) {
                         [dbArr addObject:itemModel.id];
                    }
                   
                }
            }];
            [HSDBManager saveFavoriteArrayWithTableName:[HSDBManager tableNameFavoriteWithUid] arr:dbArr];
            _favoriteDataArray = tmp;
            [_favoriteTableView reloadData];
            
        }
        else
        {
            
        }
    }];
    
}

- (void)reloadRequestData
{
    [super reloadRequestData];
    [self favoriteRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];

}

#pragma mark -
#pragma mark 取消关注
- (void)delFavoriteReqeust:(NSString *)uid itemId:(NSString *)itemId sessionCode:(NSString *)sessionCode
{
    [self showhudLoadingWithText:@"等待中" isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode,
                                    kPostJsonItemid:itemId
                                    };
    [self.httpRequestOperationManager POST:kDelFavoriteURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"取消失败"];
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
            
            if (status != nil && [status boolValue]) {
                [self showHudWithText:@"取消成功"];
                [HSDBManager deleteFavoriteItemWithTableName:[HSDBManager tableNameFavoriteWithUid] keyID:[HSPublic controlNullString:itemId]];
                [self favoriteDataWithItemID:itemId];
                [_favoriteTableView reloadData];
            }
            else
            {
                [self showHudWithText:@"取消失败"];
            }
            
        }
    }];
    
}

#pragma mark - 
#pragma mark 删除指定的收藏
- (void)favoriteDataWithItemID:(NSString *)itemID
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:_favoriteDataArray];
    
    __block HSCommodtyItemModel *itemModel = nil;
    [arr enumerateObjectsUsingBlock:^(HSCommodtyItemModel *obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj.id isEqualToString:itemID]) {
            itemModel = obj;
            *stop = YES;
        }
    }];
    
    if (itemModel != nil) {
        [arr removeObject:itemModel];
    }
    _favoriteDataArray = arr;
}


#pragma mark -
#pragma mark tableView dataSource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = _favoriteDataArray.count;
    if (num == 0 && !self.isRequestLoading) {
        [self placeViewWithImgName:@"search_no_content" text:@"还没有关注"];
    }
    else
    {
        [self removePlaceView];
    }

    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSFavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSFavoriteTableViewCell class]) forIndexPath:indexPath];
    HSCommodtyItemModel *model = _favoriteDataArray[indexPath.row];
    [cell setupWirhModel:model];
    __weak typeof(self) wself = self;
    cell.cancelBlock = ^{
        [wself delFavoriteReqeust:[HSPublic controlNullString:wself.userInfoModel.id] itemId:[HSPublic controlNullString:model.id] sessionCode:[HSPublic controlNullString:wself.userInfoModel.sessionCode]];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSCommodityDetailViewController *detailVC = [storyBorad instantiateViewControllerWithIdentifier:NSStringFromClass([HSCommodityDetailViewController class])];
    //detailVC.hidesBottomBarWhenPushed = YES;
    HSCommodtyItemModel *itemModel = _favoriteDataArray[indexPath.row];;
    detailVC.itemModel = itemModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
