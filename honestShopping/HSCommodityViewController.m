//
//  HSCommodityViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommodityViewController.h"
#import "HSCommodityDetailViewController.h"

#import "HSCommodityCollectionViewCell.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "FFScrollView.h"
#import "HSBannerHeaderCollectionReusableView.h"
#import "UIView+HSLayout.h"

#import "HSCommodtyItemModel.h"
#import "HSItemPageModel.h"
#import "HSBannerModel.h"
#import "HSAdItemModel.h"

@interface HSCommodityViewController ()<CHTCollectionViewDelegateWaterfallLayout,
UICollectionViewDataSource,
UICollectionViewDelegate,
FFScrollViewDelegate>
{
    /// 保存item所有数量
    HSItemPageModel *_pageModel;
    
    NSArray *_bannerModelsArray;
    
    NSArray *_bannerImagesArray;
    ///商品数据
    NSArray <HSCommodtyItemModel>*_itemsData;
    /// 广告位数据
    NSArray *_adsData;
    
    NSMutableDictionary *_imageSizeDic;
    
    /// 热销顶部的滚动试图
    FFScrollView *_ffScrollView;
    
    /// 顶部滚动高度约束
    NSLayoutConstraint *_ffScrollViewHeightConstraint;

    HSCommodityCollectionViewCell *_sizeCell;
    
    BOOL _isAdsLoding;
    
    /// 列宽度不相等section的size 数组
    NSArray *_firstSectionArr;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commodityTopConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *commdityCollectionView;
@end

@implementation HSCommodityViewController


static NSString *const kCommodityCellIndentifier = @"CommodityCellIndentifier";

static NSString *const kHeaderIdentifier = @"bannerHeaderIdentifier";

static NSString *const kAdsCellIdentifier = @"AdsCellIdentifier";

static const float kFFScrollViewHeight = 200;

static const NSUInteger kSizeNum = 10;

static const int kAdsCellImageViewTag = 600;


- (id)init
{
    LogFunc;
    self = [super init];
    if (self) {
        _isShowBanner = NO;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [_commdityCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommodityCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kCommodityCellIndentifier];
    [_commdityCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kAdsCellIdentifier];
    if (_isShowBanner)
    {
        //注册headerView Nib的view需要继承UICollectionReusableView
        [_commdityCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSBannerHeaderCollectionReusableView class]) bundle:nil] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier];
    }
    _commdityCollectionView.dataSource = self;
    _commdityCollectionView.delegate = self;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 2;
    if (_isShowBanner) {
         layout.headerHeight = kFFScrollViewHeight;
    }
   
    _commdityCollectionView.collectionViewLayout = layout;
    
    
    _imageSizeDic = [[NSMutableDictionary alloc] init];
    
    
    __weak typeof(self) wself = self;
    
    [_commdityCollectionView addLegendFooterWithRefreshingBlock:^{
        __strong typeof(wself) swself = wself;
        
        if ([swself->_commdityCollectionView.header isRefreshing]) {
            [self showHudWithText:@"刷新中..."];
            [swself->_commdityCollectionView.footer endRefreshing];
            return ;
        }

        /// 防止请求完了 防止多次请求最后一次
        if ((swself->_itemsData.count > 0 && _itemsData.count%kSizeNum > 0) || (swself->_pageModel != nil && [swself->_pageModel.total intValue] <= swself->_itemsData.count)) {
            [swself->_commdityCollectionView.footer noticeNoMoreData];
            return ;
        }
        
        
        [wself dataRequestWithWithCid:[HSPublic controlNullString:swself->_cateID] size:kSizeNum key:[HSPublic md5Str:[HSPublic getIPAddress:YES]] page:swself->_itemsData.count/kSizeNum + 1];
    }];
    
    [_commdityCollectionView addLegendHeaderWithRefreshingBlock:^{
        __strong typeof(wself) swself = wself;
        if ([swself->_commdityCollectionView.footer isRefreshing]) {
            [self showHudWithText:@"下拉加载中..."];
            [swself->_commdityCollectionView.header endRefreshing];
            return ;
        }
        [wself reloadDataWithWithCid:[HSPublic controlNullString:swself->_cateID] size:swself->_itemsData.count key:[HSPublic md5Str:[HSPublic getIPAddress:YES]] page:1];
    }];
    _isAdsLoding = NO;
    

}

#pragma mark 瀑布流

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    LogFunc;
    [_commdityCollectionView reloadData];
    if (_adsData.count == 0 && !_isAdsLoding) {
        [self adsRequestWithCid:[HSPublic controlNullString:_cateID ] key:[HSPublic md5Str:[HSPublic getIPAddress:YES]]];
    }
    
    if (_itemsData.count == 0 && !_commdityCollectionView.footer.isRefreshing) { /// 数据为空 并且 不在刷新
        [_commdityCollectionView.footer beginRefreshing];
    }

}


- (void)ffScrollViewInitWithSubView:(UIView *)spView
{
    if (_ffScrollView != nil && [_ffScrollView superview] == spView) {
        if (![_ffScrollView.sourceArr isEqualToArray:_bannerImagesArray]) {
            _ffScrollView.sourceArr = _bannerImagesArray;
            [_ffScrollView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(_commdityCollectionView.frame), kFFScrollViewHeight)];
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
    [_ffScrollView iniSubviewsWithFrame:CGRectMake(0, 0,CGRectGetWidth(_commdityCollectionView.frame), kFFScrollViewHeight)];
    _ffScrollView.pageControl.currentPageIndicatorTintColor = kAPPTintColor;
}

- (void)setBannerModels:(NSArray *)images
{
    if (!_isShowBanner) {
        return;
    }
    _bannerModelsArray = images;
    
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    [images enumerateObjectsUsingBlock:^(HSBannerModel *obj, NSUInteger idx, BOOL *stop) {
        if (obj.content.length > 0 ) {
            [tmp addObject:obj.content];
        }
    }];
    _bannerImagesArray = tmp;
    
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


- (void)setItemsData:(NSArray *)itemsData
{
    _itemsData = (NSArray <HSCommodtyItemModel> *)itemsData;
    [_commdityCollectionView reloadData];
}

#pragma mark -
#pragma mark  获取数据

- (void)dataRequestWithWithCid:(NSString *)cid size:(NSUInteger)size key:(NSString *)key page:(NSUInteger)page
{
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonCid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                    kPostJsonSize:[NSNumber numberWithInteger:size],
                                    kPostJsonPage:[NSNumber numberWithInteger:page]};
    
    [self.httpRequestOperationManager POST:kGetItemsByCateURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
       [_commdityCollectionView.footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response=%@",operation.responseString);
        
        [_commdityCollectionView.footer endRefreshing];
        NSString *str = (NSString *)operation.responseString;
        
        NSData *data =  [str dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        
        if ([json isKindOfClass:[NSDictionary class]] && jsonError == nil) {
            
            NSDictionary *jsonDic = (NSDictionary *)json;
            HSItemPageModel *pageModel = [[HSItemPageModel alloc] initWithDictionary:jsonDic error:nil];
            _pageModel = pageModel;
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            
            if (_itemsData.count == 0) {
                _itemsData = pageModel.item_list;
            }
            else
            {
                [tmpArray addObjectsFromArray:_itemsData];
                if ([pageModel.item_list count] > 0) {
                    [tmpArray addObjectsFromArray:pageModel.item_list];
                     _itemsData = (NSArray <HSCommodtyItemModel>*)tmpArray;
                }
                
            }
           
            [_commdityCollectionView reloadData];
            }
        
    }];
    
}

- (void)reloadDataWithWithCid:(NSString *)cid size:(NSUInteger)size key:(NSString *)key page:(NSUInteger)page
{
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonCid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                    kPostJsonSize:[NSNumber numberWithInteger:size],
                                    kPostJsonPage:[NSNumber numberWithInteger:page]};
    
    [self.httpRequestOperationManager POST:kGetItemsByCateURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        [_commdityCollectionView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response=%@",operation.responseString);
        
        [_commdityCollectionView.header endRefreshing];
        NSString *str = (NSString *)operation.responseString;
        
        NSData *data =  [str dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            [self showHudWithText:@"刷新失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        
        if ([json isKindOfClass:[NSDictionary class]] && jsonError == nil) {
            
            NSDictionary *jsonDic = (NSDictionary *)json;
            HSItemPageModel *pageModel = [[HSItemPageModel alloc] initWithDictionary:jsonDic error:nil];
            _pageModel = pageModel;
            _itemsData = pageModel.item_list;
            [_commdityCollectionView reloadData];
        }
        
    }];

}

#pragma mark-
#pragma mark 广告位数据
- (void)adsRequestWithCid:(NSString *)cid key:(NSString *)key
{
    _isAdsLoding = YES;
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonCid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                  };
    
    [self.httpRequestOperationManager POST:kGetAdsByCateURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        _isAdsLoding = NO;
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response=%@",operation.responseString);
        _isAdsLoding = NO;
        NSString *str = (NSString *)operation.responseString;
        if (str.length <= 1) {
            return ;
        }
        NSString *result = [str substringFromIndex:1];

        
        NSData *data =  [result dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return ;
        }
       
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        
        if ([json isKindOfClass:[NSArray class]] && jsonError == nil) {
            NSArray *jsonArray = (NSArray *)json;
            
            NSMutableArray *tmp = [[NSMutableArray alloc] init];
            [jsonArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                
                HSAdItemModel *itemModel = [[HSAdItemModel alloc] initWithDictionary:obj error:nil];
                [tmp addObject:itemModel];
            }];
            _adsData = tmp;
            [_commdityCollectionView reloadData];
        }
        
    }];

}




#pragma mark -
#pragma  mark collectionView dataSource and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num = 0;
    
    if (section == 0) {
        num = MIN(_adsData.count, 3);
    }
    else if (section == 1)
    {
        if (_adsData.count > 3) {
            num = 1;
        }
        else
        {
            num = 0;
        }
    }
    else if (section == 2)
    {
        if (_adsData.count > 4) {
            num = _adsData.count - 4;
        }
        else
        {
            num = 0;
        }
    }
    else
    {
        num = _itemsData.count;
    }
    
    return num;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    NSInteger num = 2;
    
    if (section == 1) {
        num = 1;
    }
    return num;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    BOOL iscon = [self p_containIndexPathWithArr:collectionView.indexPathsForVisibleItems indexPath:indexPath];
//    int res = iscon ? 1 : 0;
//    NSLog(@"ddd con = %d",res);
    
    if (indexPath.section == 3) {
        HSCommodityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommodityCellIndentifier forIndexPath:indexPath];
        HSCommodtyItemModel *itemModel = _itemsData[indexPath.row];
        //    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.img]]];
        cell.imgView.image = kPlaceholderImage;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.img]] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
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
                if (collectionView.dataSource != nil) {
                    //[collectionView reloadData];
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }
        }];
        [cell dataSetUpWithModel:itemModel];
        
        return cell;
        
    }
    else /// 广告cell
    {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAdsCellIdentifier forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[cell viewWithTag:kAdsCellImageViewTag];
        if (imgView == nil) {
            imgView = [[UIImageView alloc] init];
            imgView.translatesAutoresizingMaskIntoConstraints = NO;
            imgView.tag = kAdsCellImageViewTag;
            [cell addSubview:imgView];
            [cell HS_edgeFillWithSubView:imgView];
        }
        
        NSInteger idx;
        if (indexPath.section == 0) {
            idx = indexPath.row;
        }
        else if (indexPath.section == 1)
        {
            idx = indexPath.row + 3;
        }
        else
        {
            idx = indexPath.row + 4;
        }
        HSAdItemModel *adModel = _adsData[idx];
        imgView.image = kPlaceholderImage;
        [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,adModel.content]] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {

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
                if (collectionView.dataSource != nil ) {
                    //  [collectionView reloadData];
                    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
                
            }

        }];
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 2;
        cell.layer.borderColor = kAPPTintColor.CGColor;
        cell.layer.borderWidth = 0.5;
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        
        HSCommodtyItemModel *itemModel = _itemsData[indexPath.row];
        if (_sizeCell == nil) {
            _sizeCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HSCommodityCollectionViewCell class]) owner:nil options:nil] firstObject];//;[[HSCommodityCollectionViewCell alloc] init];
        }
        
        CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)collectionView.collectionViewLayout;
        CGRect rect = collectionView.bounds;
        rect.size.width -= layout.minimumColumnSpacing*(layout.columnCount-1) + layout.sectionInset.left + layout.sectionInset.right;
        rect.size.width /= 2.0;
        rect.size.height = INT16_MAX;
        _sizeCell.contentView.bounds = rect;
        _sizeCell.contentView.frame = rect;
        //    [_sizeCell.imgView  sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.img]]];
        _sizeCell.titlelabel.preferredMaxLayoutWidth = rect.size.width-16;
        //    _sizeCell.priceLabel.preferredMaxLayoutWidth = 80;
        //    _sizeCell.oldPricelabel.preferredMaxLayoutWidth = 40;
        [_sizeCell dataSetUpWithModel:itemModel];
        [_sizeCell.contentView updateConstraintsIfNeeded];
        [_sizeCell.contentView layoutIfNeeded];
        
        CGSize size = [_sizeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        size.width = rect.size.width;
        NSDictionary *dic = [_imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
        if (dic != nil) {
            NSValue *sizeValue = dic[kImageSizeKey];
            CGSize imgSize = [sizeValue CGSizeValue];
            CGFloat hei = imgSize.width == 0 ? 0 :(((float)imgSize.height/imgSize.width)*rect.size.width);
            //        NSLog(@"imgsize = %@ hei=%f",NSStringFromCGSize(imgSize),hei);
            size.height += hei;
        }
        else /// 占位高度 图片比例为1比1；
        {
            size.height += size.width;
        }
        return size;
    }
    else
    {
        if (indexPath.section == 0) {
            if (_firstSectionArr == nil) {
                
                CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)_commdityCollectionView.collectionViewLayout;
                CGFloat totalWitdh = CGRectGetWidth(collectionView.frame)-layout.sectionInset.left-layout.sectionInset.right-layout.minimumColumnSpacing;
                CGSize first = CGSizeMake(totalWitdh*0.4, totalWitdh*0.5);
                CGSize second = CGSizeMake(totalWitdh*0.6, (totalWitdh*0.5-5)/2.0);
                _firstSectionArr = @[[NSValue valueWithCGSize:first],[NSValue valueWithCGSize:second],[NSValue valueWithCGSize:second]];
            }
            CGSize retSize = [_firstSectionArr[indexPath.row] CGSizeValue];
            return retSize;
            
        }
        
        CGSize size = CGSizeMake(80, 60);
        NSDictionary *dic = [_imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
        if (dic != nil) {
            NSValue *sizeValue = dic[kImageSizeKey];
            size = [sizeValue CGSizeValue];
        }

        return size;
    }

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier;
    if ([kind isEqualToString: CHTCollectionElementKindSectionHeader ] && _isShowBanner && indexPath.section == 0){
        reuseIdentifier = kHeaderIdentifier;
        HSBannerHeaderCollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
        [self ffScrollViewInitWithSubView:view];
        return view;

    }else{
        
        return nil;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
{
    if (section == 0 && _isShowBanner) {
        return kFFScrollViewHeight;
    }
    return 0.0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (_isShowBanner && section == 0) {
        CGSize size = CGSizeMake(CGRectGetWidth(_commdityCollectionView.frame), kFFScrollViewHeight);
        return size;
    }
    
    return  CGSizeZero;
}

 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    HSCommodtyItemModel *itemModel = nil;
    
    NSInteger idx = 0;
    if (indexPath.section == 0) {
        idx = indexPath.row;
    }
    else if (indexPath.section == 1)
    {
        idx = indexPath.row + 3;
    }
    else if (indexPath.section == 2)
    {
        idx = indexPath.row + 4;
    }
    
    if (indexPath.section == 3) {
        itemModel = _itemsData[indexPath.row];
    }
    else
    {
        HSAdItemModel *adModel = _adsData[idx];
        itemModel = [[HSCommodtyItemModel alloc] init];
        itemModel.id = adModel.desc;
    }

    /// 点击后委托父控制器push
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(itemModel);
    }

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([_commdityCollectionView numberOfItemsInSection:section] == 1) {
         return UIEdgeInsetsMake(0, 5, 0, 5);
    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (BOOL)collectionView:(UICollectionView *)collectionView columnEqualWithForSectionAtIndex:(NSInteger)section
{
    BOOL isWidthEqual = YES;
    if (section == 0) {
        isWidthEqual = NO;
    }
    
    return isWidthEqual;
}


- (NSString *)p_keyFromIndex:(NSIndexPath *)index
{
    if (index == nil) {
        return @"";
    }
    
    NSString *result = [NSString stringWithFormat:@"indexsec%ldrow%ld",(long)index.section,(long)index.row];
    return result;
}

- (BOOL)p_containIndexPathWithArr:(NSArray *)arr indexPath:(NSIndexPath *)indexPath
{
    __block BOOL isCon = NO;
    NSLog(@"index. section= %ld row = %ld",(long)indexPath.section,(long)indexPath.row);
    [arr enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"obj. section= %ld row = %ld",(long)obj.section,(long)obj.row);
        if (obj.row == indexPath.row && obj.section == indexPath.section ) {
            isCon = YES;
            *stop = YES;
        }
        
    }];
    
    return isCon;
}

@end
