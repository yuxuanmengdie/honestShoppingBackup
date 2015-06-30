//
//  HSMineViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSMineViewController.h"
#import "HSMineOrderViewController.h"
#import "HSMineCouponViewController.h"
#import "HSLoginInViewController.h"
#import "HSMineAddressViewController.h"
#import "HSMineFavoriteViewController.h"
#import "HSPayOrderViewController.h"
#import "HSSubmitOrderViewController.h"

#import "HSMineTopTableViewCell.h"
#import "HSMineTableViewCell.h"
#import "HSMineCollectionViewCell.h"
#import "HSMineTopCollectionReusableView.h"
#import "CHTCollectionViewWaterfallLayout.h"

#import "HSUserInfoModel.h"

#import "UIImageView+WebCache.h"


@interface HSMineViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate,
CHTCollectionViewDelegateWaterfallLayout,
UIAlertViewDelegate>
{
    NSArray *_mineDataArray;
    
    HSMineTopTableViewCell *_topCell;
    
    HSUserInfoModel *_userInfoModel;
    
    NSArray *_iconArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *mineCollectionView;

@end

@implementation HSMineViewController

static NSString *const kCellIdentifier = @"HSMineViewControllerCellIdentifier";

static const int kLoginOutAlertTag = 700;

static const int kTakePhoneAlertTag = 701;

- (void)awakeFromNib
{
    /// 每次进入程序都登录，更新sessioncode
    if ([HSPublic isLoginInStatus]) {
         [self loginRequest];
    }
 
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的";
    [self setUpDataArray];
    [self getLastetUserInfoModel];
    _iconArray = @[@"icon_mine_1",@"icon_mine_2",@"icon_mine_3",@"icon_mine_4",@"icon_mine_5",@"icon_mine_6"];
    
    [_mineCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSMineCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HSMineCollectionViewCell class])];
    [_mineCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSMineTopCollectionReusableView class]) bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([HSMineTopCollectionReusableView class])];
    
    _mineCollectionView.dataSource = self;
    _mineCollectionView.delegate = self;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
//    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.columnCount = 3;
    _mineCollectionView.collectionViewLayout = layout;
    
    
}



- (void)setUpDataArray
{
    _mineDataArray = @[@"我的订单",
                       @"我的优惠券",
                       @"我的关注",
                       @"我的试吃",
                       @"联系客服",
                       @"我的地址"];
}

- (void)getLastetUserInfoModel
{
    if ([HSPublic isLoginInStatus]) {
        NSDictionary *dic = [HSPublic userInfoFromPlist];
        _userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:dic error:nil];
    }
    else
    {
        _userInfoModel = nil;
    }
 //   [_mineCollectionView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([HSPublic isLoginInStatus]) {
        [self setNavBarRightBarWithTitle:@"退出帐号" action:@selector(loginOut)];
    }

    
    [self getLastetUserInfoModel];
    if ([HSPublic isLoginInStatus]) {
        [self userInfoRequest:[HSPublic controlNullString:_userInfoModel.username] phone:[HSPublic controlNullString:_userInfoModel.phone]];
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

#pragma mark -
#pragma mark 帐号登出
- (void)loginOut
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否退出帐号" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    alertView.tag = kLoginOutAlertTag;
    [alertView show];

}

#pragma mark -
#pragma mark 登录请求
- (void)loginRequest
{
    
    if (![HSPublic isLoginInStatus]) { /// 不在登录状态
        return;
    }
    
    NSString *userName = [HSPublic lastUserName];
    NSString *passWord = [HSPublic lastPassword];
    NSString *openID = [HSPublic lastOtherOpenID];
    
    NSDictionary *parametersDic;
    NSString *loginURL = nil;
    if ([HSPublic loginType] == kAccountLoginType) { /// 帐号登录
        
        loginURL = kLoginURL;
        parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                          kPostJsonUserName:userName,
                          kPostJsonPassWord:passWord
                          };
        
    }
    else
    {
        loginURL = kOtherLoginURL;
        NSString *type = nil;
        
        if ([HSPublic loginType] == kQQLoginType) {
            type = kOtherLoginQQType;
        }
        else
        {
            type = kOtherLoginWeixinType;
        }
        parametersDic = @{kPostJsonOpenid:openID,
                          kPostJsonType:type};
        
    }
    // 142346261  123456
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager POST:loginURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            [self loginRequest];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            _userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:json error:nil];
            if (_userInfoModel.id.length > 0) { /// 登录后返回有数据
                [HSPublic saveUserInfoToPlist:[_userInfoModel toDictionary]];
            }
        }
        else
        {
            
        }
    }];

}


#pragma mark -
#pragma mark 获取个人信息
- (void)userInfoRequest:(NSString *)userName phone:(NSString *)phone
{

    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUserName:userName,
                                    kPostJsonPhone:phone
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetUserInfoURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        //[self showHudWithText:@"用户信息获取失败"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            //[self showHudWithText:@"用户信息获取失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
           // [self showHudWithText:@"用户信息获取成功"];
            
            HSUserInfoModel *infoModel = [[HSUserInfoModel alloc] initWithDictionary:json error:nil];
            if (infoModel.sessionCode.length < 1) { /// 获取的信息 不包含session 保存下来
                infoModel.sessionCode = _userInfoModel.sessionCode;
            }
            [HSPublic saveUserInfoToPlist:[infoModel toDictionary]];
            _userInfoModel = infoModel;
            [_mineCollectionView reloadData];
        }
        else
        {
           // [self showHudWithText:@"用户信息获取失败"];
        }
    }];

    
}

#pragma mark -
#pragma mark 签到
- (void)signRequestWithUid:(NSString *)uid  sessionCode:(NSString *)sessionCode
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kSignURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"签到失败"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        if (operation.responseData == nil) {
            [self showHudWithText:@"签到失败"];
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
            BOOL isSign = [tmp[kPostJsonStatus] boolValue];
            if (isSign) {
                [self showHudInWindowWithText:@"签到成功"];
                _userInfoModel.sign = isSign;
                
                if ([HSPublic isLoginInStatus]) {
                    [self userInfoRequest:[HSPublic controlNullString:_userInfoModel.username] phone:[HSPublic controlNullString:_userInfoModel.phone]];
                }

                [_mineCollectionView reloadData];
            }
            else if(tmp.allKeys.count == 1)
            {
                [self showHudInWindowWithText:@"已签到"];

            }
            else
            {
                [self showHudInWindowWithText:@"签到失败"];
            }
        }
        else
        {
            [self showHudWithText:@"签到失败"];
        }
    }];

}

#pragma mark -
#pragma  mark collectionView dataSource and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num = _mineDataArray.count;
    
    return num;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HSMineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HSMineCollectionViewCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = _mineDataArray[indexPath.row];
    cell.titleImageView.image = [UIImage imageNamed:_iconArray[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)_mineCollectionView.collectionViewLayout;
    CGFloat itemWidth = (CGRectGetWidth(_mineCollectionView.frame) - (layout.columnCount-1)*layout.minimumColumnSpacing)/3.0;
    CGFloat itemHeight = MAX(CGRectGetHeight(_mineCollectionView.frame)/4.0, 120);
    
    CGSize size = CGSizeMake(itemWidth, itemHeight);
    return size;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = NSStringFromClass([HSMineTopCollectionReusableView class]);
    if ([kind isEqualToString: CHTCollectionElementKindSectionHeader ]){
        
        HSMineTopCollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
        [view signStatus:NO];
         view.bgImageView.image = [UIImage imageNamed:@"icon_mine_headBg.jpg"];
        view.headerImageView.image = [UIImage imageNamed:@"icon_header"];
        if ([HSPublic isLoginInStatus]) {
           
            if ([HSPublic loginType] != kAccountLoginType) { // 第三方登录
                [view welcomeText:[HSPublic lastOtherUserName] isLogin:YES];
                [view.headerImageView sd_setImageWithURL:[NSURL URLWithString:[HSPublic lastOtherHeaderImgURL]] placeholderImage:[UIImage imageNamed:@"icon_header"]];
            }
            else
            {
                 [view welcomeText:[HSPublic controlNullString:_userInfoModel.phone] isLogin:YES];
            }
            [view signStatus:_userInfoModel.sign];
        }
        else
        {
            [view signStatus:NO];
            [view welcomeText:nil isLogin:NO];
            
        }
       
        
        view.pointsLabel.text = [NSString stringWithFormat:@"积分：%@",[HSPublic controlNullString:_userInfoModel.score]];
        __weak typeof(self) wself = self;
        view.signBlock = ^{ /// 如果没登录  进入登录界面
            __strong typeof(wself) swself = wself;
            if (swself == nil) {
                return ;
            }
            if (![HSPublic isLoginInStatus]){ /// 没有登录 提示登录
                [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
                return;
            }
            
            [swself signRequestWithUid:[HSPublic controlNullString:swself->_userInfoModel.id] sessionCode:[HSPublic controlNullString:swself->_userInfoModel.sessionCode]];
        };

        return view;
        
    }else{
        
        return nil;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
{
    CGFloat height = MAX(_mineCollectionView.frame.size.height/2.0, 240);
    
    return height;
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return  CGSizeZero;
//}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (![HSPublic isLoginInStatus]){ /// 没有登录 提示登录
        [self pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
        return;
    }
    
    if (indexPath.row == 0) /// 我的订单
    {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSMineOrderViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineOrderViewController class])];
        vc.userInfoModel = _userInfoModel;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) /// 我的优惠券
    {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSMineCouponViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineCouponViewController class])];
        vc.userInfoModel = _userInfoModel;
        vc.hidesBottomBarWhenPushed = YES;
        vc.title = _mineDataArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];

    }
    else if (indexPath.row == 2) /// 我的关注 即收藏
    {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSMineFavoriteViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineFavoriteViewController class])];
        vc.userInfoModel = _userInfoModel;
        vc.hidesBottomBarWhenPushed = YES;
        vc.title = _mineDataArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 3) // 我的试吃
    {
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        HSMineAddressViewController *submitVC = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineAddressViewController class])];
////        submitVC.itemNumDic = [self selectedItemNum];
////        submitVC.itemsDataArray = [self selectedItems];
//        submitVC.title = @"确认订单";
//        submitVC.hidesBottomBarWhenPushed = YES;
//        //submitVC.userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
//        [self.navigationController pushViewController:submitVC animated:YES];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"敬请期待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (indexPath.row == (_mineDataArray.count - 1) - 1) {  /// 打电话 应该提示
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"是否拨打客服电话" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        alertView.tag = kTakePhoneAlertTag;
        [alertView show];
        
    }
    else if (indexPath.row == (_mineDataArray.count - 1)) // 我的地址
    {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSMineAddressViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSMineAddressViewController class])];
        vc.userInfoModel = _userInfoModel;
        vc.addressType = HSMineAddressReadType;
        vc.hidesBottomBarWhenPushed = YES;
        vc.title = _mineDataArray[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }

    
}

#pragma mark - 
#pragma mark alertView的委托
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kTakePhoneAlertTag) { /// 提示打电话
        
        if (buttonIndex == 1) { // 拨打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://02525326589"]];
        }

    }
    
    else if (alertView.tag == kLoginOutAlertTag)
    {
        if (buttonIndex == 1) { //退出帐号
            [HSPublic setLoginOut];
            _userInfoModel = nil;
            [_mineCollectionView reloadData];
            self.navigationItem.rightBarButtonItem = nil;

        }

    }
}



/*
#pragma mark - 
#pragma mark tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (section != 1) {
        num = 1;
    }
    else
    {
        num = _mineDataArray.count;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        HSMineTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSMineTopTableViewCell class]) forIndexPath:indexPath];
        if ([HSPublic isLoginInStatus]) {
            [cell welcomeText:_userInfoModel.username isLogin:YES];
            [cell signStatus:_userInfoModel.sign];
        }
        else
        {
            [cell signStatus:NO];
            [cell welcomeText:nil isLogin:NO];
        }
        
        __weak typeof(self) wself = self;
        cell.signBlock = ^{ /// 如果没登录  进入登录界面
            __strong typeof(wself) swself = wself;
            if (swself == nil) {
                return ;
            }
            if (![HSPublic isLoginInStatus]){ /// 没有登录 提示登录
                [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
                return;
            }

            [swself signRequestWithUid:swself->_userInfoModel.id sessionCode:swself->_userInfoModel.sessionCode];
        };
        
        return cell;
    }
    else
    {
        HSMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSMineTableViewCell class]) forIndexPath:indexPath];
        if (indexPath.section == 1) {
            cell.mainTitleLaabel.text = _mineDataArray[indexPath.row];
        }
        else
        {
            cell.mainTitleLaabel.text = @"186-5506-1482";
        }
        
        cell.iconImageView.image = [UIImage imageNamed:@"icon_star_full"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    if (indexPath.section == 0) {
        if (_topCell == nil) {
            _topCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSMineTopTableViewCell class])];
            _topCell.bounds = tableView.bounds;
        }
        [_topCell.contentView updateConstraintsIfNeeded];
        [_topCell.contentView layoutIfNeeded];
        
        height = [_topCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![HSPublic isLoginInStatus]){ /// 没有登录 提示登录
        [self pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
        return;
    }
    
    if (0 == indexPath.section) { // 个人信息
        
    }
    else if (1 == indexPath.section) /// 订单相关
    {
        
    }
    else /// 打电话
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://18655061482"]];
    }
}
 */
@end
