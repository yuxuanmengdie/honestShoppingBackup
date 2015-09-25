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
#import "HSCommentListViewController.h"
#import "HSShoppingCartViewController.h"

#import "HSBuyNumView.h"
#import "HSCommodityDetailTableViewCell.h"
#import "HSCommodityItemTopBannerView.h"
#import "UIView+HSLayout.h"
#import "HMSegmentedControl.h"
#import "HSSegmentControlView.h"

#import "HSCommodityItemDetailPicModel.h"
#import "HSUserInfoModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "HSDBManager.h"
#import "UIImageView+WebCache.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "WXApi.h"
#import "MJRefresh.h"

@interface HSCommodityDetailViewController ()<UITableViewDataSource,
UITableViewDelegate,UMSocialUIDelegate>
{
    HSCommodityItemDetailPicModel *_detailPicModel;
    
     NSMutableDictionary *_itemImageSizeDic;
    
    AFHTTPRequestOperationManager *_operationManager;
    
    HSCommodityItemTopBannerView *_placeheadView;
    
    HSSegmentControlView *_segmentControl;
    
    UIScrollView *_contentScrollView;
    
    UIScrollView *_segmentSrcollView;
    
    HSCommentListViewController *_commentVC;
    
    // 约束
    NSLayoutConstraint *_infoTopConstraint;
    
    NSLayoutConstraint *_infoBottomConstraint;
    
    NSLayoutConstraint *_contentScrollTopContraint;
    
    NSLayoutConstraint *_contentScrollBottomContrait;
    
}

@property (strong, nonatomic) UITableView *detailTableView;

@property (strong, nonatomic) UITableView *infoTableView;

@property (weak, nonatomic) IBOutlet HSBuyNumView *buyNumView;

/// 是否已经添加到购物车
@property (assign, nonatomic) BOOL isCollected;

@end

@implementation HSCommodityDetailViewController

static const float kSegmentHei = 40;

static NSString  *const kTopCellIndentifier = @"topCellIndentifer";

- (void)dealloc
{
    [_detailTableView endUpdates];
    [_infoTableView endUpdates];
    _detailTableView.dataSource = nil;
    _detailTableView.delegate = nil;
    _infoTableView.dataSource = nil;
    _infoTableView.dataSource = nil;
    _detailTableView = nil;
    _operationManager = nil;
    [[_operationManager operationQueue] cancelAllOperations];
    [self removeObserver:self forKeyPath:@"isCollected"];
    
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _itemImageSizeDic = [[NSMutableDictionary alloc] init];
    _buyNumView.hidden = YES;
    self.title = @"商品详情";
   
    [self infoTableViewInit];
    [self segmentControlInit];
    [self contentInit];

    // kvo 检测 isCollected
    [self addObserver:self forKeyPath:@"isCollected" options:NSKeyValueObservingOptionNew context:nil];
    [self requestDetailByItemID:[HSPublic controlNullString:_itemModel.id]];
    [self buyViewBlock];
    
    [_detailTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommodityDetailTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCommodityDetailTableViewCell class])];
    [_infoTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTopCellIndentifier];
    _detailTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    _infoTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self.view bringSubviewToFront:_buyNumView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 是否添加到购物车
    BOOL collect = [HSDBManager selectedItemWithTableName:[HSDBManager tableNameWithUid] keyID:_itemModel.id] == nil ? NO : YES;
    self.isCollected = collect;
    
}

- (void)infoTableViewInit
{
    _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _infoTableView.backgroundColor = ColorRGB(244, 244, 244);
    [self.view addSubview:_infoTableView];
    _infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_infoTableView addGifFooterWithRefreshingTarget:self refreshingAction:@selector(loadToDetail)];
    [_infoTableView.gifFooter setTitle:@"拖动查看商品详情" forState:MJRefreshFooterStateIdle];
    [_infoTableView.gifFooter setTitle:@"释放查看商品详情" forState:MJRefreshFooterStateRefreshing];
    
    id top = self.topLayoutGuide;
    _buyNumView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_infoTableView)]];
    _infoTopConstraint = [NSLayoutConstraint constraintWithItem:_infoTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:top attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
     _infoBottomConstraint = [NSLayoutConstraint constraintWithItem:_buyNumView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_infoTableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[_infoTopConstraint,_infoBottomConstraint]];
    
}

- (void)segmentControlInit
{
    HSSegmentControlView *segmentedControl3 = [[HSSegmentControlView alloc] initWithSectionTitles:@[@"详情", @"评价"]];
    _segmentControl = segmentedControl3;
    _segmentControl.backgroundColor = [UIColor redColor];
    __weak typeof(self) wself = self;
    [segmentedControl3 setActionBlock:^(NSUInteger index) {
        NSLog(@"Selected index %ld (via block)", (long)index);
        __strong typeof(wself) swself = wself;
        
        if (index == 0) {
            [swself->_segmentSrcollView setContentOffset:CGPointMake(0, 0) animated:YES];
            
        }
        else
        {
            [swself->_segmentSrcollView setContentOffset:CGPointMake(CGRectGetWidth(swself->_segmentSrcollView.frame), 0) animated:YES];
        }
    }];
    segmentedControl3.selectedIndicatorColor = kAPPLightGreenColor;
    segmentedControl3.normalIndicatorColor = [UIColor lightGrayColor];
    
    [segmentedControl3 setSelctedIndex:0];
    
}

- (void)contentInit
{
    _buyNumView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view layoutIfNeeded];
    float hei = CGRectGetMinY(_buyNumView.frame);
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _contentScrollView.alwaysBounceHorizontal = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.hidden = YES;
    [self.view addSubview:_contentScrollView];
    _contentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _contentScrollView.backgroundColor = ColorRGB(244, 244, 244);
    [_contentScrollView addGifHeaderWithRefreshingTarget:self refreshingAction:@selector(loadToInfo)];
    [_contentScrollView.gifHeader setTitle:@"拖动查看商品详情" forState:MJRefreshHeaderStateIdle];
    [_contentScrollView.gifHeader setTitle:@"松开查看商品详情" forState:MJRefreshHeaderStatePulling];
    [_contentScrollView.gifHeader setTitle:@"松开查看商品详情" forState:MJRefreshHeaderStateRefreshing];
    _contentScrollView.gifHeader.updatedTimeHidden = YES;
    
    _segmentSrcollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _segmentSrcollView.alwaysBounceHorizontal = NO;
    //_segmentSrcollView.bounces = NO;
    _segmentSrcollView.showsHorizontalScrollIndicator = NO;
    _segmentSrcollView.showsVerticalScrollIndicator = NO;
    _segmentSrcollView.scrollEnabled = YES;
    _segmentSrcollView.pagingEnabled = YES;
    _segmentSrcollView.delegate = self;
    [_contentScrollView addSubview:_segmentSrcollView];
    _segmentSrcollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _detailTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _detailTableView.backgroundColor = [UIColor whiteColor];
    [_segmentSrcollView addSubview:_detailTableView];
    _detailTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _commentVC = [stroyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSCommentListViewController class])];
    _commentVC.itemID = _itemModel.id;
    [self addChildViewController:_commentVC];
    [_commentVC didMoveToParentViewController:self];
    [_segmentSrcollView addSubview:_commentVC.view];
    _commentVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_contentScrollView addSubview:_segmentControl];
    _segmentControl.translatesAutoresizingMaskIntoConstraints = NO;


    UIView *tmpView = _commentVC.view;
    // _segmentControl 的约束
    [_contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentControl]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_segmentControl)]];
    [_contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_segmentControl(40)][_segmentSrcollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_segmentControl,_segmentSrcollView)]];
    [_contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_segmentControl attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_contentScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    // commentVC.view  和 detailTableViw的约束
    [_segmentSrcollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_detailTableView(==tmpView)][tmpView]|" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_detailTableView,tmpView)]];
     [_segmentSrcollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_detailTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_detailTableView,tmpView)]];
    [_segmentSrcollView addConstraint:[NSLayoutConstraint constraintWithItem:_detailTableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_segmentSrcollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [_segmentSrcollView addConstraint:[NSLayoutConstraint constraintWithItem:_detailTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_segmentSrcollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    //_segmentSrcollView的约束
    [_contentScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_segmentSrcollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_segmentSrcollView)]];
    [_contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_segmentSrcollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_contentScrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-kSegmentHei]];
    [_contentScrollView addConstraint:[NSLayoutConstraint constraintWithItem:_segmentSrcollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_contentScrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    // _contontView 约束
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentScrollView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentScrollView)]];

    _contentScrollTopContraint = [NSLayoutConstraint constraintWithItem:_contentScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:hei];
    _contentScrollBottomContrait = [NSLayoutConstraint constraintWithItem:_contentScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_buyNumView attribute:NSLayoutAttributeTop multiplier:1.0 constant:hei];
    [self.view addConstraints:@[_contentScrollTopContraint,_contentScrollBottomContrait]];

}

#pragma  mark - 构建navBar 的rightItems
- (UIBarButtonItem *)favoraiteNavItem
{
    UIImage *img = [UIImage imageNamed:@"icon_favorite_unSel30"];
    // 是否添加到 我的关注中
    BOOL isCare = [HSDBManager selectFavoritetemWithTableName:[HSDBManager tableNameFavoriteWithUid] keyID:_itemModel.id] == nil ? NO : YES;
    if (isCare) {
        img = [UIImage imageNamed:@"icon_favorite_Sel30"];
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addToFavorite) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return item;
}

- (UIBarButtonItem *)shareNavItem
{
    UIBarButtonItem *item = nil;
    
    if (!(![WXApi isWXAppInstalled] && ![QQApiInterface isQQInstalled])) {
        //判断是否有微信
        NSLog(@"至少安装了一个");
        UIImage *img = [UIImage imageNamed:@"icon_share"];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:img forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    
    return item;

}

- (void)rightNavItems
{
    if ([self shareNavItem] != nil) {
        self.navigationItem.rightBarButtonItems = @[[self shareNavItem],[self favoraiteNavItem]];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [self favoraiteNavItem];
    }

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
    
    
    NSString *shareURLStr = @"http://ecommerce.news.cn/index.php?g=api&m=Test&a=download";
    [UMSocialWechatHandler setWXAppId:@"wxf674afd7fa6b3db1" appSecret:@"768ef498760a90567afeac93211abfa9" url:shareURLStr];
    [UMSocialQQHandler setQQWithAppId:@"1104470651" appKey:@"1VATaXjYJuiJ0itg" url:shareURLStr];
    NSString *shareText = @"“放心吃”是由新华社江苏分社、新华网移动互联网产品研发基地打造的优质农副产品掌上电商平台。【安心选，放心吃】";//[NSString stringWithFormat:@"%@\n%@", _detailPicModel.title,_detailPicModel.intro];//@"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"icon_app_60"];          //分享内嵌图片
    
    //调用快速分享接口
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMengAppKey
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone,nil]//nil UMShareToSina
                                       delegate:self];

}

// 添加到 关注
- (void)addToFavorite
{
    if (![HSPublic isLoginInStatus]) {
        [self showHudWithText:@"请先登录"];
        [self pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
        return ;
    }
    
    HSUserInfoModel *infoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
    
    [self collectItemRequestWithID:[HSPublic controlNullString:_detailPicModel.id] uid:[HSPublic controlNullString:infoModel.id] sessionCode:[HSPublic controlNullString:infoModel.sessionCode]];
    
}

#pragma mark - 下拉到详细的
- (void)loadToDetail
{
    [_infoTableView.gifFooter endRefreshing];
    
    [self.view layoutIfNeeded];
    float hei = CGRectGetMinY(_buyNumView.frame);
    _infoTopConstraint.constant = -hei;
    _infoBottomConstraint.constant = -hei;
    _contentScrollTopContraint.constant = 0;
    _contentScrollBottomContrait.constant = 0;
    [self.view updateConstraintsIfNeeded];
    _infoTableView.hidden = NO;
    _contentScrollView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _infoTableView.hidden = YES;
        _contentScrollView.hidden = NO;
    }];
    
}

- (void)loadToInfo
{
    [_contentScrollView.gifHeader endRefreshing];
    
    [self.view layoutIfNeeded];
    float hei = CGRectGetMinY(_buyNumView.frame);
    _infoTopConstraint.constant = 0;
    _infoBottomConstraint.constant = 0;
    _contentScrollTopContraint.constant = hei;
    _contentScrollBottomContrait.constant = hei;
    [self.view updateConstraintsIfNeeded];
    _contentScrollView.hidden = NO;
    _infoTableView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _infoTableView.hidden = NO;
        _contentScrollView.hidden = YES;
    }];
    
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
    
    _buyNumView.collectBlock = ^(UIButton *collctBtn){ /// 添加到购物车
        
        __strong typeof(wself) swself = wself;
        if (![HSPublic isLoginInStatus]) {
            [wself showHudWithText:@"请先登录"];
            [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
            return ;
        }
        
        BOOL isSuc = [HSDBManager saveCartListWithTableName:[HSDBManager tableNameWithUid] keyID:swself->_detailPicModel.id data:[swself->_detailPicModel toDictionary]];
        if (isSuc) {
            [swself showHudWithText:@"添加购物车成功"];
            swself.isCollected = isSuc;
        }
    };
    
    _buyNumView.cartBlock = ^{
        
        __strong typeof(wself) swself = wself;
        if (![HSPublic isLoginInStatus]) {
            [wself showHudWithText:@"请先登录"];
            [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
            return ;
        }
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        HSShoppingCartViewController *cartVC = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSShoppingCartViewController class])];
        [swself.navigationController pushViewController:cartVC animated:YES];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        
//        NSLog(@"response=%@",operation.responseString);
        NSString *str = (NSString *)operation.responseString;
        NSString *result = str;
        
        NSData *data =  [result dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
             [swself showReqeustFailedMsg];
            [swself showHudWithText:@"加载失败"];
            swself.navigationItem.rightBarButtonItem = [swself shareNavItem];
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
            
            swself.infoTableView.dataSource = swself;
            swself.infoTableView.delegate = swself;
            [swself.infoTableView reloadData];
            swself->_detailTableView.dataSource = swself;
           swself->_detailTableView.delegate = swself;
            [swself->_detailTableView reloadData];
            
            swself->_buyNumView.stepper.maximum = [swself->_detailPicModel.maxbuy intValue];
            
            [swself rightNavItems];
        }
    }];
}

#pragma mark -
#pragma mark  添加关注
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
                [HSDBManager saveFavoriteWithTableName:[HSDBManager tableNameFavoriteWithUid] keyID:_itemModel.id];
                
            }
            
            [self rightNavItems];
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
    NSInteger count = 0;
    if (tableView == _infoTableView) {
        count = 1;
    }
    else
    {
        count = _detailPicModel.tuwen.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _infoTableView) {// 顶部轮播图所在的tableviewcell
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTopCellIndentifier forIndexPath:indexPath];
        HSCommodityItemTopBannerView *headView = (HSCommodityItemTopBannerView *)[cell.contentView viewWithTag:501];
        
        if (headView == nil) {
            headView = [[HSCommodityItemTopBannerView alloc] initWithFrame:cell.frame];
            headView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:headView];
            cell.contentView.bounds = tableView.bounds;
            headView.tag = 501;
            [self headViewAutoLayoutInCell:cell headView:headView];
            headView.bannerView.sourceArr = [self controlBannerArr:_detailPicModel.banner];
  
        }
        float hei = _placeheadView == nil ? headView.bannerHeight : _placeheadView.bannerHeight;
        [headView.bannerView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(tableView.frame), hei)];
        headView.bannerView.pageControl.currentPageIndicatorTintColor = kAPPTintColor;
        [headView.infoView setupWithItemModel:_detailPicModel];
        if (_sanpinType > 0) {
            [headView sanpinImageTag:_sanpinType];
        }
        
        //[headView.infoView collcetStatus:_isCollected];
        
        //headView.infoView.collectButton.hidden = YES;
        __weak typeof(self) wself = self;
        headView.infoView.colletActionBlock = ^(UIButton *btn){
            __strong typeof(wself) swself = wself;
            
            if (![HSPublic isLoginInStatus]) {
                [swself showHudInWindowWithText:@"请先登录"];
                [swself pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
                return ;
            }
            
            NSDictionary *dic = @{[HSPublic controlNullString:swself->_detailPicModel.id]:[NSNumber numberWithInt:(int)swself->_buyNumView.stepper.value]};
            NSArray *arr = @[swself->_detailPicModel];
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            HSSubmitOrderViewController *submitVC = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSSubmitOrderViewController class])];
            submitVC.itemNumDic = dic;
            submitVC.itemsDataArray = arr;
            submitVC.title = @"确认订单";
            submitVC.userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
            [wself.navigationController pushViewController:submitVC animated:YES];

            
//            BOOL isSuc = [HSDBManager saveCartListWithTableName:[HSDBManager tableNameWithUid] keyID:swself->_detailPicModel.id data:[swself->_detailPicModel toDictionary]];
//            if (isSuc) {
//                [swself showHudWithText:@"添加购物车成功"];
//                swself->_isCollected = isSuc;
//                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
    
        HSCommodityDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommodityDetailTableViewCell class]) forIndexPath:indexPath];
        
        NSString *imgPath = _detailPicModel.tuwen[indexPath.row];
        //cell.detailImageView.image = kPlaceholderImage;
        
        __weak typeof(self) wself = self;
        NSIndexPath *tmp = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:[self p_introImgFullUrl:imgPath]]  placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            __strong typeof(wself) swself = wself;
            if (swself == nil) {
                return ;
            }
            
            if (image) {
                // do something with image
                
                NSValue *imgSize =  [NSValue valueWithCGSize:image.size];
                NSDictionary *dic = [swself->_itemImageSizeDic objectForKey:[swself p_keyFromIndex:tmp]];
                if (dic != nil ) {
                    NSURL *imgURL = dic[kImageURLKey];
                    NSValue *sizeValue = dic[kImageSizeKey];
                    if ([imgURL isEqual:imageURL] && [sizeValue isEqual:imgSize]) {
                        return ;
                    }
                }
                
                NSDictionary *tmpDic = @{kImageSizeKey:imgSize,
                                         kImageURLKey:imageURL};
                
                [swself->_itemImageSizeDic setObject:tmpDic forKey:[swself p_keyFromIndex:tmp]];
                
                if (swself->_detailTableView.dataSource != nil) {
                    NSLog(@"????%@",[swself p_keyFromIndex:tmp]);
                    [tableView reloadData];
                }
                
            }
            
        }];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    CGFloat height = 200.0;

    
    if (tableView == _infoTableView) {
        
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
        
    }
    else
    {
        NSDictionary *dic = [_itemImageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
        //NSLog(@"index.row = %d sizeDic = %@ ",indexPath.row, _itemImageSizeDic);
        if (dic != nil) {
            NSValue *sizeValue = dic[kImageSizeKey];
            if (sizeValue.CGSizeValue.width != 0.0) { /// 宽度为0时 防止除0错误
            float per = (float)sizeValue.CGSizeValue.height / sizeValue.CGSizeValue.width;
            height = per * CGRectGetWidth(tableView.frame);
            }
        }

    }
    
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


#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _segmentSrcollView) {
        
        CGPoint point = scrollView.contentOffset;
        NSLog(@"%f,%f",point.x,point.y);
        [_segmentControl indicatorLocation:point.x/(float)scrollView.contentSize.width];

    }
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

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isCollected"]) {
        
       //NSNumber *tmp = change[NSKeyValueChangeNewKey];
        
        [_buyNumView collectTitleWithStatus:_isCollected];
    }
}

@end
