//
//  HSHomeViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-29.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSHomeViewController.h"
#import "HSCommodityDetailViewController.h"

#import "CHTCollectionViewWaterfallLayout.h"
#import "UIImageView+WebCache.h"
#import "FFScrollView.h"
#import "HSBannerHeaderCollectionReusableView.h"
#import "UIView+HSLayout.h"
#import "HSHomeCollectionViewCell.h"
#import "MJRefresh.h"

#import "HSCommodtyItemModel.h"
#import "HSBannerModel.h"
#import "HSAdItemModel.h"
#import "HSCouponModel.h"
#import "HSUserInfoModel.h"


@interface HSHomeViewController ()<CHTCollectionViewDelegateWaterfallLayout,
UICollectionViewDataSource,
UICollectionViewDelegate,
FFScrollViewDelegate>
{
    FFScrollView *_ffScrollView;
    
    NSArray *_bannerModelsArray;
    
    NSArray *_bannerImagesArray;

    NSLayoutConstraint *_ffScrollViewHeightConstraint;
    
    NSArray *_sectionSizeArr;
    
    NSArray *_itemsDataArray;
    
    NSArray *_couponDataArray;
    
    NSArray *_sectionImageArray;
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *homeCollectionView;
@end

@implementation HSHomeViewController

static NSString *const kHeaderIdentifier = @"bannerHeaderIdentifier";

static NSString *const kFFHeaderIdentifier = @"ffscrollViewHeaderIdentifier";

static const float kFFScrollViewHeight = 200;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _sectionImageArray = @[@"icon_home_section1",@"icon_home_section2",@"icon_home_section3",@"icon_home_section4"];
    _sectionImageArray = @[@"icon_home_section1",@"icon_home_section2",@"icon_home_section3",@"icon_home_section4",@"icon_home_section5",@"icon_home_section6"];
    
    [_homeCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSHomeCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HSHomeCollectionViewCell class])];
            //注册headerView Nib的view需要继承UICollectionReusableView
    [_homeCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSBannerHeaderCollectionReusableView class]) bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier];
    [_homeCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:kFFHeaderIdentifier];

    _homeCollectionView.dataSource = self;
    _homeCollectionView.delegate = self;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerInset = UIEdgeInsetsZero;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 2;
    _homeCollectionView.collectionViewLayout = layout;
    
    __weak typeof(self) wself = self;
    [_homeCollectionView addLegendHeaderWithRefreshingBlock:^{
         [wself getIndexItemRequest];
    }];
    [_homeCollectionView.header beginRefreshing];
    //[self getIndexItemRequest];

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
#pragma mark 获取banner 图片
- (void)getBannerImages
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]};
    [self.httpRequestOperationManager GET:kGetBannerURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self getBannerImages];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response=%@",operation.responseString);
        NSString *str = (NSString *)operation.responseString;
        if (str.length <= 1) {
            return ;
        }
        NSString *result = [str substringFromIndex:1];
        
        NSData *data =  [result dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            [self getBannerImages];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        if ([json isKindOfClass:[NSArray class]] && jsonError == nil) {
            
            NSArray *jsonArray = (NSArray *)json;
            
            NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
            NSMutableArray *tmpBannner = [[NSMutableArray alloc] initWithCapacity:jsonArray.count];
            [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                HSBannerModel *model = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                NSString *fullURL = [NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,model.content];
                [tmpBannner addObject:fullURL];
                model.content = fullURL;
                [tmpArray addObject:model];
                
            }];
            _bannerModelsArray = tmpArray;
            _bannerImagesArray = tmpBannner;
            [_homeCollectionView reloadSections:[[NSIndexSet alloc]initWithIndex:0]];
            //[_homeCollectionView reloadData];
        }
    }];
}


#pragma mark - 
#pragma mark 获取首页商品
- (void)getIndexItemRequest
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]};
    [self.httpRequestOperationManager POST:kGetIndexItemURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenMsg];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenMsg];
        [_homeCollectionView.header endRefreshing];
        if (operation.responseData == nil) {
            [self getIndexItemRequest];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSArray class]]) {
            NSArray *jsonArr = (NSArray *)json;
            NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:jsonArr.count];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    HSBannerModel *bannerModel = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                    [tmpArr addObject:bannerModel];
                }
                
            }];
            
            _itemsDataArray = tmpArr;
            [_homeCollectionView reloadData];
            
            [self couponListRequest];
            [self getBannerImages];
            
        }
        else
        {
            
        }
    }];

}

#pragma mark -
#pragma mark 获取优惠券列表
- (void)couponListRequest
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]};
    [self.httpRequestOperationManager POST:kGetCouponListURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);

        if (operation.responseData == nil) {
            [self couponListRequest];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
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
             [_homeCollectionView reloadSections:[[NSIndexSet alloc]initWithIndex:0]];
            //[_homeCollectionView reloadData];
        }
        else
        {
            
        }
    }];

}

#pragma mark - 
#pragma mark 领取优惠券
- (void)blindCouponRequestWithUid:(NSString *)uid couponId:(NSString *)couponId sessionCode:(NSString *)sessionCode
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonCouponId:couponId,
                                    kPostJsonSessionCode:sessionCode};
    [self.httpRequestOperationManager POST:kBlindCouponWithUserURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%s failed\n%@",__func__,operation.responseString);
        
        if (operation.responseData == nil) {
            [self showHudInWindowWithText:@"领取失败"];
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
            BOOL isSign = [jsonDic[kPostJsonStatus] boolValue];
            if (isSign) {
                [self showHudInWindowWithText:@"领取成功"];
            }
            else if (jsonDic.allKeys.count == 1)
            {
                [self showHudInWindowWithText:@"已领取"];
                
            }
            else
            {
                [self showHudInWindowWithText:@"领取失败"];
            }

        }
        else
        {
            
        }
    }];

}

- (void)ffScrollViewInitWithSubView:(UIView *)spView
{
    if (_ffScrollView != nil && [_ffScrollView superview] == spView) {
        if (![_ffScrollView.sourceArr isEqualToArray:_bannerImagesArray]) {
            _ffScrollView.sourceArr = _bannerImagesArray;
            [_ffScrollView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(_homeCollectionView.frame), kFFScrollViewHeight)];
            _ffScrollView.pageControl.currentPageIndicatorTintColor = kAPPTintColor;
        }
        return;
    }
    
    _ffScrollView = [[FFScrollView alloc] initWithFrame:CGRectZero];
    _ffScrollView.pageViewDelegate = self;
    [spView addSubview:_ffScrollView];
    _ffScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *vfl1 = @"H:|[_ffScrollView]|";
    NSString *vfl2 = @"V:|[_ffScrollView]";
    NSDictionary *dic = NSDictionaryOfVariableBindings(_ffScrollView,spView);
    NSArray *arr1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
    NSArray *arr2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
    
    _ffScrollViewHeightConstraint  = [NSLayoutConstraint constraintWithItem:_ffScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kFFScrollViewHeight];
    [spView addConstraints:arr1];
    [spView addConstraints:arr2];
    [spView addConstraint:_ffScrollViewHeightConstraint];
    
    _ffScrollView.sourceArr = _bannerImagesArray;
    [_ffScrollView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(_homeCollectionView.frame), kFFScrollViewHeight)];
    _ffScrollView.pageControl.currentPageIndicatorTintColor = kAPPTintColor;
}

#pragma mark -
#pragma mark 轮播图 delegate
- (void)scrollViewDidClickedAtPage:(NSInteger)pageNumber
{
    HSBannerModel *model = _bannerModelsArray[pageNumber];
    HSCommodtyItemModel *itemModel = [[HSCommodtyItemModel alloc] init];
    itemModel.id = model.desc;
    /// 点击后委托父控制器push
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(itemModel);
    }
    
}



#pragma mark -
#pragma  mark collectionView dataSource and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _sectionImageArray.count + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num = 4;
    
    if (section == 0) {
        num = _couponDataArray.count;
    }
    else if (section == 1 || section ==  3)
    {
        num = 5;
        //num = 4;
    }
    
    return num;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    NSInteger num = 2;
    
    if (section == 0) {
        num = 3;
    }
    return num;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    HSHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HSHomeCollectionViewCell class]) forIndexPath:indexPath];
    cell.contentImageView.image = kPlaceholderImage;
    
    NSString *imgUrl = nil;
    
    if (indexPath.section == 0) { /// 优惠券的图片前缀
        HSCouponModel *coupModel = _couponDataArray[indexPath.row];
        imgUrl = [NSString stringWithFormat:@"%@%@",kCoupImageHeaderURL,coupModel.img];
    }
    else
    {
        int sum = 0;
        for (int j=1; j<indexPath.section; j++) {
            sum += [collectionView numberOfItemsInSection:j];
        }
        
        //HSBannerModel *bannerModel = _itemsDataArray[(indexPath.section-1)*[collectionView numberOfItemsInSection:indexPath.section]+indexPath.row];
         HSBannerModel *bannerModel = _itemsDataArray[sum+indexPath.row];
        imgUrl = [NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,bannerModel.content];
    }
    
    
    [cell.contentImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            // do something with image
    
            NSValue *imgSize =  [NSValue valueWithCGSize:image.size];
            NSDictionary *dic = [self.imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
            if (dic != nil ) {
                NSURL *imgURL = dic[kImageURLKey];
                NSValue *sizeValue = dic[kImageSizeKey];
                if ([imgURL isEqual:imageURL] && [sizeValue isEqual:imgSize]) {
                    return ;
                }
            }
            
            NSDictionary *tmpDic = @{kImageSizeKey:imgSize,
                                     kImageURLKey:imageURL};
            
            [self.imageSizeDic setObject:tmpDic forKey:[self p_keyFromIndex:indexPath]];
            if (collectionView.dataSource != nil) {
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
            
        }
    }];
    
    [cell setNeedsLayout];
    return cell;
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section != 0) {
        if (_sectionSizeArr == nil) {
            
            CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)_homeCollectionView. collectionViewLayout;
            CGFloat totalWitdh = CGRectGetWidth(collectionView.frame)-layout.sectionInset.left-layout.sectionInset.right-layout.minimumColumnSpacing;
            CGSize first = CGSizeMake(totalWitdh*0.4, totalWitdh*0.5);
            CGSize second = CGSizeMake(totalWitdh*0.6, (totalWitdh*0.5-5)/2.0);
            CGSize total = CGSizeMake( CGRectGetWidth(collectionView.frame)-layout.sectionInset.left-layout.sectionInset.right, (CGRectGetWidth(collectionView.frame)-layout.sectionInset.left-layout.sectionInset.right)*0.4);
            _sectionSizeArr = @[[NSValue valueWithCGSize:first],[NSValue valueWithCGSize:second],[NSValue valueWithCGSize:second],[NSValue valueWithCGSize:total],[NSValue valueWithCGSize:total],[NSValue valueWithCGSize:total]];
        }
        CGSize retSize = [_sectionSizeArr[indexPath.row] CGSizeValue];
        return retSize;
        
    }
    
    CGSize size = CGSizeMake(10, 6);
    NSDictionary *dic = [self.imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
    if (dic != nil) {
        NSValue *sizeValue = dic[kImageSizeKey];
        size = [sizeValue CGSizeValue];
    }
    
    return size;
    
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = kHeaderIdentifier;
    if ([kind isEqualToString: CHTCollectionElementKindSectionHeader ] && indexPath.section == 0){
        reuseIdentifier = kFFHeaderIdentifier;
        UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
        [self ffScrollViewInitWithSubView:view];
        return view;
        
    }
    else if ([kind isEqualToString: CHTCollectionElementKindSectionHeader] && indexPath.section > 0)
    {
        HSBannerHeaderCollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
        
        UIImageView *sectionImgView = (UIImageView *)[view viewWithTag:604];
        if (sectionImgView == nil) {
            sectionImgView = [[UIImageView alloc] init];
            sectionImgView.translatesAutoresizingMaskIntoConstraints = NO;
            [view addSubview:sectionImgView];
            sectionImgView.tag = 604;
            [view HS_edgeFillWithSubView:sectionImgView];
        }
        NSString *imgName  = _sectionImageArray[indexPath.section-1];
        UIImage *img = [UIImage imageNamed:imgName];
        sectionImgView.image = img;

        return view;
    }
    else
    {
        return nil;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
{
    CGFloat hei = 0.0;
    if (section == 0) {
        hei = kFFScrollViewHeight;
    }
    else
    {
        NSString *imgName  = _sectionImageArray[section-1];
        UIImage *img = [UIImage imageNamed:imgName];
        hei = (float)img.size.height / img.size.width * collectionView.frame.size.width;
    }
    return hei;
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    if ( section == 0) {
//        CGSize size = CGSizeMake(CGRectGetWidth(_homeCollectionView.frame), kFFScrollViewHeight);
//        return size;
//    }
//    
//    return  CGSizeZero;
//}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) { /// 领取优惠券
        if (![HSPublic isLoginInStatus]) {
            [self showHudWithText:@"请先登录"];
            return;
        }
        
        HSCouponModel *model = _couponDataArray[indexPath.row];
        HSUserInfoModel *userModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
        [self blindCouponRequestWithUid:[HSPublic controlNullString:userModel.id] couponId:[HSPublic controlNullString:model.id] sessionCode:[HSPublic controlNullString:userModel.sessionCode]];
        
    }
   else
   {
       int sum = 0;
       for (int j=1; j<indexPath.section; j++) {
           sum += [collectionView numberOfItemsInSection:j];
       }

       
       //HSBannerModel *bannerModel = _itemsDataArray[(indexPath.section-1)*[collectionView numberOfItemsInSection:indexPath.section]+indexPath.row];
        HSBannerModel *bannerModel = _itemsDataArray[sum+indexPath.row];
       /// 点击后委托父控制器push
       HSCommodtyItemModel *itemModel = [[HSCommodtyItemModel alloc] init];
       itemModel.id = bannerModel.desc;
       if (self.cellSelectedBlock) {
           self.cellSelectedBlock(itemModel);
       }

   }
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
//    if ([_homeCollectionView numberOfItemsInSection:section] == 1) {
//        return UIEdgeInsetsMake(0, 5, 0, 5);
//    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (BOOL)collectionView:(UICollectionView *)collectionView columnEqualWithForSectionAtIndex:(NSInteger)section
{
    BOOL isWidthEqual = YES;
    if (section != 0) {
        isWidthEqual = NO;
    }
    
    return isWidthEqual;
}


#pragma mark - 
#pragma mark index转换成key
- (NSString *)p_keyFromIndex:(NSIndexPath *)index
{
    if (index == nil) {
        return @"";
    }
    
    NSString *result = [NSString stringWithFormat:@"indexsec%ldrow%ld",(long)index.section,(long)index.row];
    return result;
}

@end
