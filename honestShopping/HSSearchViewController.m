//
//  HSSearchViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-5-2.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSearchViewController.h"
#import "HSSearchResultModel.h"
#import "HSCommodityViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "HSCommodityCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "HSCommodityDetailViewController.h"

@interface HSSearchViewController ()<UISearchBarDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
CHTCollectionViewDelegateWaterfallLayout>
{
    UISearchBar *_searchBar;
    
    HSSearchResultModel *_resultModel;
    
    NSString *_lastSearchText;
    
    NSArray *_searchArray;
    
    HSCommodityCollectionViewCell *_sizeCell;
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *searchCollectionView;

//@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
//
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation HSSearchViewController

static NSString *const kCommodityCellIndentifier = @"CommodityCellIndentifier";

static const int kSizeNum = 10;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self searchBarSetUp];
    [self searchCollectViewLayout];
    [self setNavBarRightBarWithTitle:@"    " action:nil];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
}


- (void)searchCollectViewLayout
{
    [_searchCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommodityCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kCommodityCellIndentifier];
        _searchCollectionView.dataSource = self;
    _searchCollectionView.delegate = self;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 2;
    _searchCollectionView.collectionViewLayout = layout;

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
#pragma mark  搜索框
- (void)searchBarSetUp
{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = kAPPTintColor;
    searchBar.frame = CGRectMake(0, 0,1000, 30);
    searchBar.delegate = self;
//    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.placeholder = @"输入关键字";
    _searchBar = searchBar;
    self.navigationItem.titleView = searchBar;
    //searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kdeviceToken"];
}

#pragma mark -
#pragma mark searchDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    if (_searchBar.text.length < 1) {
        [self showHudWithText:@"关键字不能为空"];
        return;
    }
    
    _lastSearchText = _searchBar.text;
    [self searchRequest:_searchBar.text page:1 size:kSizeNum isMore:NO];

}


#pragma mark -
#pragma mark  搜索接口
- (void)searchRequest:(NSString *)keyWord page:(int)page size:(int)size isMore:(BOOL)isMore
{
    [self showhudLoadingWithText:nil isDimBackground:YES];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonPage:[NSNumber numberWithInt:page],
                                    kPostJsonSize:[NSNumber numberWithInt:size],
                                    kPostJsonKeyWord:keyWord
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetSearchListURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        [self hiddenHudLoading];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%s failed\n%@",__func__,operation.responseString);
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"搜索失败"];
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&jsonError];
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *tmpDic = (NSDictionary *)json;
            
            _resultModel = [[HSSearchResultModel alloc] initWithDictionary:tmpDic error:nil];
            if (page < _resultModel.totalPage.intValue) { /// 还可以上拉更多
                __weak typeof(self) wself = self;
                [_searchCollectionView addLegendFooterWithRefreshingBlock:^{
                    __strong typeof(wself) swself = wself;
                    [swself searchRequest:swself->_lastSearchText page:(int)(swself->_searchArray.count/kSizeNum) + 1 size:kSizeNum isMore:YES];
                }];
            }
            else
            {
                [_searchCollectionView.footer noticeNoMoreData];
            }
            
            if (!isMore) { /// 不是加载更多
                _searchArray = _resultModel.item_list;
            }
            else
            {
                NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:_searchArray];
                [tmp addObjectsFromArray:_resultModel.item_list];
                _searchArray = tmp;
            }
            
            [_searchCollectionView reloadData];
            
        
        }
    }];

}

#pragma mark -
#pragma  mark collectionView dataSource and delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_searchArray.count == 0) {
        [self placeViewWithImgName:@"search_no_content" text:@"没有搜索内容"];
    }
    else
    {
        [self removePlaceView];
    }
    
    return _searchArray.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HSCommodityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommodityCellIndentifier forIndexPath:indexPath];
    HSCommodtyItemModel *itemModel = _searchArray[indexPath.row];
    //    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.img]]];
    cell.imgView.image = nil;
    [cell dataSetUpWithModel:itemModel];
    
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.img]] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            // do something with image
            
            NSValue *imgSize =  [NSValue valueWithCGSize:image.size];
            NSDictionary *dic = [self.imageSizeDic objectForKey:[self keyFromIndex:indexPath]];
            if (dic != nil ) {
                NSURL *imgURL = dic[kImageURLKey];
                NSValue *sizeValue = dic[kImageSizeKey];
                if ([imgURL isEqual:imageURL] && [sizeValue isEqual:imgSize]) {
                    return ;
                }
            }
            
            NSDictionary *tmpDic = @{kImageSizeKey:imgSize,
                                     kImageURLKey:imageURL};
            
            [self.imageSizeDic setObject:tmpDic forKey:[self keyFromIndex:indexPath]];
            if (collectionView.dataSource != nil) {
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }

    }];
        
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HSCommodtyItemModel *itemModel = _searchArray[indexPath.row];
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
    NSDictionary *dic = [self.imageSizeDic objectForKey:[self keyFromIndex:indexPath]];
    if (dic != nil) {
        NSValue *sizeValue = dic[kImageSizeKey];
        CGSize imgSize = [sizeValue CGSizeValue];
        CGFloat hei = imgSize.width == 0 ? 0 :(((float)imgSize.height/imgSize.width)*rect.size.width);
        //        NSLog(@"imgsize = %@ hei=%f",NSStringFromCGSize(imgSize),hei);
        size.height += hei;
    }
    
    //    NSLog(@"rect=%@ %@", NSStringFromCGRect(rect),NSStringFromCGSize(size));
    return size;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    HSCommodtyItemModel *itemModel = _searchArray[indexPath.row];
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSCommodityDetailViewController *detailVC = [board instantiateViewControllerWithIdentifier:NSStringFromClass([HSCommodityDetailViewController class])];
    detailVC.itemModel = itemModel;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}
@end
