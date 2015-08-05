//
//  HSCommodityDetailViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-31.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityDetailViewController.h"
#import "HSLoginInViewController.h"
#import "HSSubmitOrderViewController.h"

#import "HSBuyNumView.h"
#import "HSCommodityDetailTableViewCell.h"
#import "HSCommodityItemTopBannerView.h"
#import "UIView+HSLayout.h"

#import "HSCommodityItemDetailPicModel.h"
#import "HSUserInfoModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "HSDBManager.h"
#import "UIImageView+WebCache.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "WXApi.h"

@interface HSCommodityDetailViewController ()<UITableViewDataSource,
UITableViewDelegate,UMSocialUIDelegate>
{
    HSCommodityItemDetailPicModel *_detailPicModel;
    
     NSMutableDictionary *_imageSizeDic;
    
    AFHTTPRequestOperationManager *_operationManager;
    /// 是否已经关注
    BOOL _isCollected;
    
    HSCommodityItemTopBannerView *_placeheadView;
}

@property (weak, nonatomic) IBOutlet UITableView *detailTableView;

@property (weak, nonatomic) IBOutlet HSBuyNumView *buyNumView;

@end

@implementation HSCommodityDetailViewController

///顶部的轮播图放到
static const int kTopExistCellNum = 1;

static NSString  *const kTopCellIndentifier = @"topCellIndentifer";

//- (void)awakeFromNib
//{
//    self.hidesBottomBarWhenPushed = YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageSizeDic = [[NSMutableDictionary alloc] init];
    _buyNumView.hidden = YES;
    self.title = @"商品详情";
   
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(shareAction)];
//    self.navigationItem.rightBarButtonItem = shareItem;
    
    [self requestDetailByItemID:[HSPublic controlNullString:_itemModel.id]];
    [self buyViewBlock];
    _isCollected = [HSDBManager selectedItemWithTableName:[HSDBManager tableNameWithUid] keyID:_itemModel.id] == nil ? NO : YES;
    
    [_detailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommodityDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCommodityDetailTableViewCell class])];
    [_detailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTopCellIndentifier];
    _detailTableView.separatorStyle = UITableViewCellSelectionStyleNone;
//    _detailTableView.dataSource = self;
//    _detailTableView.delegate = self;

    
    
}

#pragma mark -
#pragma mark rightNavBar action 分享
- (void)shareAction
{
    //设置微信AppId，设置分享url，默认使用友盟的网址
//    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.umeng.com/social"];
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:@"507fcab25270157b37000010"
//                                      shareText:@"你要分享的文字"
//                                     shareImage:[UIImage imageNamed:@"arrow"]
//                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,nil]
//                                       delegate:self];
    
    
    [UMSocialWechatHandler setWXAppId:@"wxf674afd7fa6b3db1" appSecret:@"768ef498760a90567afeac93211abfa9" url:[self p_shareURLWithModel:_detailPicModel]];
    [UMSocialQQHandler setQQWithAppId:@"1104470651" appKey:@"1VATaXjYJuiJ0itg" url:[self p_shareURLWithModel:_detailPicModel]];
    NSString *shareText = [NSString stringWithFormat:@"%@\n%@", _detailPicModel.title,_detailPicModel.intro];//@"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"icon_app_60"];          //分享内嵌图片
    
    //调用快速分享接口
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMengAppKey
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,nil]//nil UMShareToSina
                                       delegate:self];

}

#pragma mark -
#pragma mark 分享deleagte

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}


- (void)buyViewBlock
{
    if ([HSPublic isLoginInStatus] && [HSDBManager selectFavoritetemWithTableName:[HSDBManager tableNameFavoriteWithUid] keyID:_itemModel.id].length > 0 ) {
        _buyNumView.collectBtn.selected = YES;
    }
    __weak typeof(self) wself = self;
    _buyNumView.buyBlock = ^(int num){ /// 购买
        __strong typeof(wself) swself = wself;
        if (![HSPublic isLoginInStatus]) {
            [wself showHudWithText:@"请先登录"];
            [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
            return ;
        }

        NSDictionary *dic = @{[HSPublic controlNullString:swself->_detailPicModel.id]:[NSNumber numberWithInt:num]};
        NSArray *arr = @[swself->_detailPicModel];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSSubmitOrderViewController *submitVC = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSSubmitOrderViewController class])];
        submitVC.itemNumDic = dic;
        submitVC.itemsDataArray = arr;
        submitVC.title = @"确认订单";
        submitVC.userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
        [wself.navigationController pushViewController:submitVC animated:YES];
        
    };
    
    _buyNumView.collectBlock = ^(UIButton *collctBtn){ /// 关注
        
        __strong typeof(wself) swself = wself;
        if (![HSPublic isLoginInStatus]) {
            [wself showHudWithText:@"请先登录"];
            [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
            return ;
        }
        
        HSUserInfoModel *infoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
        
        [wself collectItemRequestWithID:[HSPublic controlNullString:swself->_detailPicModel.id] uid:[HSPublic controlNullString:infoModel.id] sessionCode:[HSPublic controlNullString:infoModel.sessionCode]];
    };
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
#pragma mark 获取详细信息
- (void)requestDetailByItemID:(NSString *)itemID
{
    [self showNetLoadingView];
    _operationManager = [[AFHTTPRequestOperationManager alloc] init];
    AFHTTPRequestOperationManager *manager = _operationManager;//[AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonid:itemID};
    __weak typeof(self) wself = self;
    [manager POST:kGetItemByIdURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [wself showReqeustFailedMsg];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong typeof(wself) swself = wself;
        if (swself == nil) {
            return ;
        }
        
        NSLog(@"response=%@",operation.responseString);
        NSString *str = (NSString *)operation.responseString;
        NSString *result = str;
        
        NSData *data =  [result dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
             [swself showReqeustFailedMsg];
            [swself showHudWithText:@"加载失败"];
            return ;
        }

        [swself hiddenMsg];
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        if ([json isKindOfClass:[NSDictionary class]] && jsonError == nil) {
            
            swself->_detailPicModel = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:json error:&jsonError];
            
            if (swself->_detailPicModel.id == nil || jsonError != nil) {
                [swself showReqeustFailedMsg];
                return;
            }
            
            swself.buyNumView.hidden = NO;
            swself->_detailTableView.dataSource = swself;
           swself->_detailTableView.delegate = swself;

            [swself->_detailTableView reloadData];
            
            swself->_buyNumView.stepper.maximum = [swself->_detailPicModel.maxbuy intValue];
            
            if (!(![WXApi isWXAppInstalled] && ![QQApiInterface isQQInstalled])) {
                //判断是否有微信
                NSLog(@"至少安装了一个");
                [self setNavBarRightBarWithTitle:@"分享" action:@selector(shareAction)];
            }
        
        }
    }];
}

#pragma mark -
#pragma mark  底部添加关注
- (void)collectItemRequestWithID:(NSString *)itemID uid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
   
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonItemid:itemID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kAddFavoriteURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self showHudWithText:@"关注失败"];
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"关注失败"];
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
            BOOL isSuccess = [tmpDic[kPostJsonStatus] boolValue];
            _buyNumView.collectBtn.selected = YES;
            if (isSuccess) {
                [self showHudWithText:@"关注成功"];
                [HSDBManager saveFavoriteWithTableName:[HSDBManager tableNameFavoriteWithUid] keyID:_itemModel.id];
            }
            else
            {
                 [self showHudWithText:@"已关注"];
                
            }

        }
        else
        {
            [self showHudWithText:@"关注失败"];
        }
    }];

}


#pragma mark -
#pragma mark  重新加载
- (void)reloadRequestData
{
    [super reloadRequestData];
    [self requestDetailByItemID:[HSPublic controlNullString:_itemModel.id]];
}

#pragma mark -
#pragma mark tableview dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _detailPicModel.tuwen.count + kTopExistCellNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {// 顶部轮播图所在的tableviewcell
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTopCellIndentifier forIndexPath:indexPath];
        //cell.contentView.backgroundColor = [UIColor redColor];
//        for (UIView *subView in cell.contentView.subviews) {
//            [subView removeFromSuperview];
//        }
        HSCommodityItemTopBannerView *headView = (HSCommodityItemTopBannerView *)[cell.contentView viewWithTag:501];
        
        
        if (headView == nil) {
            headView = [[HSCommodityItemTopBannerView alloc] initWithFrame:cell.frame];
            headView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:headView];
            cell.contentView.bounds = tableView.bounds;
            headView.tag = 501;
             //headView.frame = cell.contentView.frame;
            [self headViewAutoLayoutInCell:cell headView:headView];
            headView.bannerView.sourceArr = [self controlBannerArr:_detailPicModel.banner];
  
        }
        float hei = _placeheadView == nil ? headView.bannerHeight : _placeheadView.bannerHeight;
        [headView.bannerView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.frame), hei)];
        headView.bannerView.pageControl.currentPageIndicatorTintColor = kAPPTintColor;
//        headView.infoView.titleLabel.text = [NSString stringWithFormat:@"%@ %@",_detailPicModel.title,_detailPicModel.standard];
//        headView.infoView.priceLabel.text = [NSString stringWithFormat:@"%@元",_detailPicModel.price];
        [headView.infoView setupWithItemModel:_detailPicModel];
        if (_sanpinType > 0) {
            [headView sanpinImageTag:_sanpinType];
        }
        
        [headView.infoView collcetStatus:_isCollected];
        __weak typeof(self) wself = self;
        headView.infoView.colletActionBlock = ^(UIButton *btn){
            __strong typeof(wself) swself = wself;
            
            if (![HSPublic isLoginInStatus]) {
                [swself showHudInWindowWithText:@"请先登录"];
                [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
                return ;
            }
            
            BOOL isSuc = [HSDBManager saveCartListWithTableName:[HSDBManager tableNameWithUid] keyID:swself->_detailPicModel.id data:[swself->_detailPicModel toDictionary]];
            if (isSuc) {
                [swself showHudWithText:@"添加购物车成功"];
                swself->_isCollected = isSuc;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        
        return cell;
    }
    
    HSCommodityDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommodityDetailTableViewCell class]) forIndexPath:indexPath];
    
    NSString *imgPath = _detailPicModel.tuwen[indexPath.row - kTopExistCellNum];
    cell.detailImageView.image = kPlaceholderImage;
    [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:[self p_introImgFullUrl:imgPath]]  placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            // do something with image
            NSValue *imgSize =  [NSValue valueWithCGSize:image.size];
            NSDictionary *dic = [_imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
            if (dic != nil ) {
                NSURL *imgURL = dic[kImageURLKey];
                NSValue *sizeValue = dic[kImageSizeKey];
                if ([imgURL isEqual:imageURL] && [sizeValue isEqual:imgSize]) {
                    return ;
                }
            }
            
            NSDictionary *tmpDic = @{kImageSizeKey:imgSize,
                                     kImageURLKey:imageURL};
            
            [_imageSizeDic setObject:tmpDic forKey:[self p_keyFromIndex:indexPath]];
            
            if (tableView.dataSource != nil) {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic ];
            }
            
        }

    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 200.0;

    
    if (0 == indexPath.row) {
        
        if (_placeheadView == nil) {
           _placeheadView = [[HSCommodityItemTopBannerView alloc] initWithFrame:CGRectZero];
            _placeheadView.bounds = tableView.bounds;
            [_placeheadView setNeedsLayout];
            [self.view addSubview:_placeheadView];
            _placeheadView.translatesAutoresizingMaskIntoConstraints = NO;
            _placeheadView.hidden = YES;
            __weak typeof(tableView) wtableView = tableView;
            _placeheadView.heightChangeBlcok = ^{
                [wtableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            };
            _placeheadView.bannerView.sourceArr = [self controlBannerArr:_detailPicModel.banner];
            [_placeheadView.bannerView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.frame), _placeheadView.bannerHeight)];


        }
        
        _placeheadView.infoView.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame) - 16*2;
        if (_sanpinType > 0) {
            _placeheadView.infoView.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.frame) - 16*2 - 60 - 3;
        }
        [_placeheadView.infoView setupWithItemModel:_detailPicModel];
        
        [_placeheadView updateConstraintsIfNeeded];
        [_placeheadView layoutIfNeeded];
        
        height = [_placeheadView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
        //height = 317;
        
    }
    
    //return height;
    
    else
    {
       
        NSDictionary *dic = [_imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
        //NSLog(@"index.row = %d sizeDic = %@ ",indexPath.row, _imageSizeDic);
        if (dic != nil) {
            NSValue *sizeValue = dic[kImageSizeKey];
            if (sizeValue.CGSizeValue.width != 0.0) { /// 宽度为0时 防止除0错误
            float per = (float)sizeValue.CGSizeValue.height / sizeValue.CGSizeValue.width;
            height = per * CGRectGetWidth(tableView.frame);
            }
        }

    }
     NSLog(@"index.row = %ld height   %f",(long)indexPath.row,height);
    
    return height;
     
}



#pragma mark -
#pragma mark tableViewCell 添加的视图添加约束
- (void)headViewAutoLayoutInCell:(UITableViewCell *)cell headView:(UIView *)headView
{
    NSString *vfl1 = @"H:|[headView]|";
    NSString *vfl2 = @"V:|[headView]|";
    NSDictionary *dic = NSDictionaryOfVariableBindings(headView);
    NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
    NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
    [cell.contentView addConstraints:cons1];
    [cell.contentView addConstraints:cons2];
    
}

#pragma mark -
#pragma mark tableViewCell 处理banner的路径
- (NSArray *)controlBannerArr:(NSArray *)arr
{
    if (arr.count < 1) {
        return nil;
    }
    
    NSMutableArray *retArr = [[NSMutableArray alloc] init];
    
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        NSString *fullPath = [NSString stringWithFormat:@"%@%@",kImageHeaderURL,obj];
        [retArr addObject:fullPath];
    }];
    
    return retArr;
}


#pragma mark -
#pragma mark tableView 处理介绍图片的url
- (NSString *)p_introImgFullUrl:(NSString *)oriUrl
{
    if (oriUrl.length < 1) {
        return nil;
    }
    NSString *result = @"";
    NSString *pre = [oriUrl substringWithRange:NSMakeRange(0, 1)];
    if ([pre isEqualToString:@"."]) {
        result = [oriUrl stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:kCommodityImgURLHeader];

    }
    else
    {
        result = [NSString stringWithFormat:@"%@%@",kCommodityImgURLHeader,oriUrl];
    }
    return result;
}

- (NSString *)p_keyFromIndex:(NSIndexPath *)index
{
    if (index == nil) {
        return @"";
    }
    
    NSString *result = [NSString stringWithFormat:@"indexsec%ldrow%ld",(long)index.section,(long)index.row];
    return result;
}

#pragma mark -
#pragma mark 分享的地址 //http://ecommerce.news.cn/index.php?m=Item&a=index&cid=363&id=423
- (NSString *)p_shareURLWithModel:(HSCommodityItemDetailPicModel *)model
{
    NSString *result = [NSString stringWithFormat:@"%@/index.php?m=Item&a=index&cid=%@&id=%@",kURLHeader,model.cate_id,model.id];
    
    return result;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)dealloc
{
    
    [_detailTableView endUpdates];
    _detailTableView.dataSource = nil;
    _detailTableView.delegate = nil;
    _detailTableView = nil;
    _operationManager = nil;
    [[_operationManager operationQueue] cancelAllOperations];

    NSLog(@"%s",__func__);
   
}
@end
