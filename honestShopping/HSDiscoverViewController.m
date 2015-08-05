//
//  HSDiscoverViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-4.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSDiscoverViewController.h"
#import "HSCommodityDetailTableViewCell.h"
#import "HSBannerModel.h"
#import "UIImageView+WebCache.h"
#import "HSCommodtyItemModel.h"
#import "HSCommodityDetailViewController.h"
#import "UIView+HSLayout.h"
#import "UIImageView+WebCache.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "MJRefresh.h"

#import "HSUserInfoModel.h"

@interface HSDiscoverViewController ()<UICollectionViewDataSource,
UICollectionViewDelegate,
CHTCollectionViewDelegateWaterfallLayout>
{
    NSArray *_discoverArray;
    
    HSUserInfoModel *_userInfoModel;
    
    BOOL _isVIP;
}

@property (weak, nonatomic) IBOutlet UICollectionView *discoverCollectionView;


@end

@implementation HSDiscoverViewController

static NSString *const kHeaderIdentifier = @"headerCellIdentifier";

static NSString *const kCellIdentifier = @"AdsCellIdentifier";

static const int kFirstSectionNum = 3;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发现生活";
    [_discoverCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    [_discoverCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier];
    
    _discoverCollectionView.dataSource = self;
    _discoverCollectionView.delegate = self;
    [_discoverCollectionView setAlwaysBounceVertical:YES];
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerInset = UIEdgeInsetsZero;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 2;
    _discoverCollectionView.collectionViewLayout = layout;


    _isVIP = NO;
    
    __weak typeof(self) wself = self;
    [_discoverCollectionView addLegendHeaderWithRefreshingBlock:^{
        [wself discoverRequest];
    }];
    [_discoverCollectionView.header beginRefreshing];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([HSPublic isLoginInStatus]) {
       _userInfoModel =[[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
        _isVIP = [_userInfoModel.is_vip isEqualToString:@"1"];
    }
    else
    {
        _userInfoModel = nil;
        _isVIP = NO;
    }
    
    [_discoverCollectionView reloadData];
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
#pragma mark 获取discover 数据
- (void)discoverRequest
{
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]]
                                   };
    __weak typeof(self) wself = self;
    [self.httpRequestOperationManager POST:kGetDiscoverURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [_discoverCollectionView.header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_discoverCollectionView.header endRefreshing];
        __strong typeof(wself) swself = wself;
        if (swself == nil) {
            return ;
        }
        
        NSLog(@"response=%@",operation.responseString);
        NSString *str = (NSString *)operation.responseString;
        NSString *result = str;
        
        NSData *data =  [result dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            [swself showHudWithText:@"加载失败"];
            return ;
        }
       
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        if ([json isKindOfClass:[NSArray class]] && jsonError == nil) {
            
            NSArray *tmpJson = (NSArray *)json;
            NSMutableArray *tmp = [[NSMutableArray alloc] init];
            [tmpJson enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                HSBannerModel *model = [[HSBannerModel alloc] initWithDictionary:obj error:nil];
                NSString *fullURL = [NSString stringWithFormat:@"%@%@",kBannerImageHeaderURL,model.content];
                model.content = fullURL;
                [tmp addObject:model];
            }];
            
            _discoverArray = tmp;
            [_discoverCollectionView reloadData];
        }
    }];

}

- (void)reloadRequestData
{
    [super reloadRequestData];
    [_discoverCollectionView.header beginRefreshing];
}

#pragma mark - 
#pragma mark 判断是否会员
- (void)isVIPWithUid:(NSString *)uid sessionCode:(NSString *)sessionCode
{
    [self showhudLoadingInWindowWithText:nil isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonSessionCode:sessionCode
                                    };
    [self.httpRequestOperationManager POST:kIsVIPURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
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
        
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDic = (NSDictionary *)json;
            
            BOOL status = [jsonDic[kPostJsonStatus] boolValue];
            if (jsonDic.allKeys.count == 1 ) {
                _isVIP = status;
                if (_isVIP) {
                    [_discoverCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UICollectionViewScrollPositionBottom];
                }
                else
                {
                    [self showHudWithText:@"您还不是会员"];
                }
            }
        }
        else
        {
            
        }
    }];

}
#pragma mark -
#pragma mark  collection dataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (section == 0) {
        count = MIN(3, _discoverArray.count);
    }
    else
    {
        count = _discoverArray.count > 3 ? _discoverArray.count-3:0;
    }
    return count;
}

//-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(CGRectGetWidth(collectionView.frame), 200);
//}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[view viewWithTag:701];
        if (imgView == nil) {
            imgView = [[UIImageView alloc] init];
            imgView.translatesAutoresizingMaskIntoConstraints = NO;
            [view addSubview:imgView];
            [view HS_edgeFillWithSubView:imgView];
        }
        imgView.image = [UIImage imageNamed:@"icon_discover_head"];
        return view;

    }
    
    return nil;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:499];
    if (imgView == nil) {
        imgView = [[UIImageView alloc] init];
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        imgView.tag = 499;
        [cell addSubview:imgView];
        [cell HS_edgeFillWithSubView:imgView];
    }
    
    HSBannerModel *model;
    if (indexPath.section == 0) {
        model = _discoverArray[indexPath.row];
    }
    else
    {
        NSInteger count = _discoverArray.count > kFirstSectionNum ? _discoverArray.count-kFirstSectionNum:0;
        model = _discoverArray[count + kFirstSectionNum-1];
    }
    imgView.image = kPlaceholderImage;
    [imgView sd_setImageWithURL:[NSURL URLWithString:model.content] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
            
            // NSLog(@"cell   %d  ob=%@",indexPath.row,_imageSizeDic[ind]);
            if (_discoverCollectionView.dataSource != nil) {
                [_discoverCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
    }

    }];
    
    return cell;
}

-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize rstSize = CGSizeZero;// CGSizeMake(50, 60);
    NSDictionary *dic = [self.imageSizeDic objectForKey:[self p_keyFromIndex:indexPath]];
    
    if (dic != nil) {
        
        NSValue *sizeValue = dic[kImageSizeKey];
        if (sizeValue.CGSizeValue.width != 0) {
            
        }
        rstSize = sizeValue.CGSizeValue;
    }
    NSLog(@"size=%@",NSStringFromCGSize(rstSize));
    return rstSize;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) { // 会员区
        
        if (![HSPublic isLoginInStatus]) {
            [self showHudWithText:@"请先登录"];
            return ;
        }
        
        if (!_isVIP) {
            [self isVIPWithUid:[HSPublic controlNullString:_userInfoModel.id] sessionCode:[HSPublic controlNullString:_userInfoModel.sessionCode]];
            return;
        }
        
    }
    
    
    HSBannerModel *model = _discoverArray[indexPath.row];
    HSCommodtyItemModel *itemModel = [[HSCommodtyItemModel alloc] init];
    itemModel.id = model.desc;
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSCommodityDetailViewController *detailVC = [board instantiateViewControllerWithIdentifier:NSStringFromClass([HSCommodityDetailViewController class])];
    detailVC.itemModel = itemModel;
    [self.navigationController pushViewController:detailVC animated:YES];

}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    CGFloat hei = 0;
    if (section == 0) {
        UIImage *image = [UIImage imageNamed:@"icon_discover_head"];
        hei = (CGFloat)image.size.height / image.size.width * collectionView.frame.size.width;
    }
    return hei;
}

- (NSString *)p_keyFromIndex:(NSIndexPath *)index
{
    if (index == nil) {
        return @"";
    }
    
    NSString *result = [NSString stringWithFormat:@"indexsec%ldrow%ld",(long)index.section,(long)index.row];
    return result;
}


@end
