//
//  HSMineAddressViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-26.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineAddressViewController.h"
#import "HSEditAddressViewController.h"
#import "HSAddressDetailViewController.h"

#import "HSAddressTableViewCell.h"

#import "HSAddressModel.h"

@interface HSMineAddressViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    NSArray *_addressDataArray;
    
    HSAddressTableViewCell *_palaceCell;
}

@property (weak, nonatomic) IBOutlet UITableView *addressTableView;
@end

@implementation HSMineAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_addressType == HSMineAddressReadType) {
        [self setNavBarRightBarWithTitle:@"新增地址" action:@selector(addNewAddress)];
    }
    else
    {
        [self setNavBarRightBarWithTitle:@"管理" action:@selector(controlAddress)];
    }
    
    
    [_addressTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSAddressTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSAddressTableViewCell class])];
    
    _addressTableView.tableFooterView = [[UIView alloc] init];
    _addressTableView.dataSource = self;
    _addressTableView.delegate = self;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self addressRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
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
#pragma mark 获取我的地址
- (void)addressRequestWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kGetAddressURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
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
        _addressDataArray = nil; /// 重置地址信息
        
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
                    HSAddressModel *model = [[HSAddressModel alloc] initWithDictionary:obj error:nil];
                    [tmpArr addObject:model];
                }
                
            }];
            
            _addressDataArray = tmpArr;
            [_addressTableView reloadData];
        }
        else
        {
            [_addressTableView reloadData];
        }
    }];
    
}

- (void)reloadRequestData
{
    [self addressRequestWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
}

#pragma mark -
#pragma mark 添加新地址
- (void)addNewAddress
{
    UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSEditAddressViewController *editVC = [stroyboard instantiateViewControllerWithIdentifier:NSStringFromClass([HSEditAddressViewController class])];
    editVC.userInfoModel = _userInfoModel;
    editVC.title = @"新增收货地址";
    editVC.addressChangeType = HSeditaddressByAddType;
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark -
#pragma mark 管理地址
- (void)controlAddress
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSMineAddressViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineAddressViewController class])];
    vc.userInfoModel = _userInfoModel;
    vc.addressType = HSMineAddressReadType;
    vc.title = @"我的地址";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark tableView dataSource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = _addressDataArray.count;
    
    if (num == 0 && !self.isRequestLoading) {
        [self placeViewWithImgName:@"search_no_content" text:@"还没有地址信息，请新增"];
    }
    else
    {
        [self removePlaceView];
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSAddressTableViewCell class]) forIndexPath:indexPath];
    HSAddressModel *model = _addressDataArray[indexPath.row];
    
    if (_addressType == HSMineAddressReadType) {
       [cell setupWithModel:model];
    }
    else
    {
        [cell dataWithModel:model selectAddressID:_addressID];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_palaceCell == nil) {
        _palaceCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSAddressTableViewCell class])];
        _palaceCell.contentView.bounds = tableView.bounds;
    }
    HSAddressModel *model = _addressDataArray[indexPath.row];
    [_palaceCell setupWithModel:model];
    _palaceCell.detailLabel.preferredMaxLayoutWidth = _palaceCell.detailLabel.frame.size.width;
    [_palaceCell.contentView updateConstraintsIfNeeded];
     [_palaceCell.contentView layoutIfNeeded];
    CGFloat height = [_palaceCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_addressType == HSMineAddressReadType) {
        HSAddressModel *model = _addressDataArray[indexPath.row];
        UIStoryboard *stroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSAddressDetailViewController *detailVC = [stroyboard instantiateViewControllerWithIdentifier:NSStringFromClass([HSAddressDetailViewController class])];
        detailVC.addressModel = model;
        detailVC.userInfoModel = _userInfoModel;
        detailVC.title = @"收货地址";
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else
    {
        HSAddressModel *model = _addressDataArray[indexPath.row];
        
        if (self.selectBlock) {
            self.selectBlock(model);
        }
        [self backAction:nil];
    }
    
   
}

-(void)viewDidLayoutSubviews
{
    if ([self.addressTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.addressTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.addressTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.addressTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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


@end
