//
//  HSCommentListViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSCommentListViewController.h"
#import "ZLPhoto.h"
#import "MJRefresh.h"

#import "HSCommentInfoView.h"
#import "HSCommentItemTableViewCell.h"
#import "HSCommentFilterTableViewCell.h"
#import "HSCommentImgTableViewCell.h"
#import "UIView+HSLayout.h"

#import "HSCommentListModel.h"
#import "HSCommentInfoModel.h"

// 评论筛选
typedef NS_ENUM(NSUInteger, HSCommentFilterType) {
    HSCommentTotalType = 0, // 查看全部评论
    HSCommentImgType, // 看图
};

@interface HSCommentListViewController ()<UITableViewDataSource,
UITableViewDelegate,
ZLPhotoPickerBrowserViewControllerDataSource,
ZLPhotoPickerBrowserViewControllerDelegate>
{
    NSArray *_commentArray;
    
    NSArray *_commentImgArray;
    
    HSCommentInfoModel *_infoModel;
    
    HSCommentItemTableViewCell *_holderItemCell;
    // 默认 HSCommentTotalType
    HSCommentFilterType _filterType;
    
    // 浏览每条评论图片的array
    NSArray *_browsePhotoArray;
    
    UIImageView *_photoTmpView;
    
    //
    BOOL _commentlistLoading;
    
    BOOL _commentImgLoading;
}

@property (weak, nonatomic) IBOutlet UITableView *commentTableView;

@end

@implementation HSCommentListViewController

static const NSUInteger kSizeNum = 10;

static NSString *const kCellIndentifierSection0 = @"kCellIndentifierSection0";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _commentlistLoading = NO;
    _commentImgLoading = NO;
    
    _filterType = HSCommentTotalType;
    [_commentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIndentifierSection0];
    [_commentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommentItemTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCommentItemTableViewCell class])];
    [_commentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommentFilterTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCommentFilterTableViewCell class])];
    [_commentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSCommentImgTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCommentImgTableViewCell class])];
    

    [self dataReload];
    [_commentTableView.legendHeader beginRefreshing];
    [_commentTableView.legendFooter beginRefreshing];
    
    if ([_commentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_commentTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_commentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_commentTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

// 数据上拉 下拉 的响应方法
- (void)dataReload
{
    __weak typeof(self) wself = self;
    // 下拉刷新
    [_commentTableView addLegendHeaderWithRefreshingBlock:^{
        __strong typeof(wself) swself = wself;
        if (swself == nil) {
            return ;
        }
        
        NSInteger num = kSizeNum;
        [swself commentInfoListRequestWithItemid:[HSPublic controlNullString:swself.itemID] size:num key:[HSPublic getIPAddress:YES] page:1];
    }];
    
    // 上拉加载更多
    [_commentTableView addLegendFooterWithRefreshingBlock:^{
        __strong typeof(wself) swself = wself;
        if (swself == nil) {
            return ;
        }

        switch (swself->_filterType) {
            case HSCommentTotalType:
            {
                if (swself->_commentArray.count%kSizeNum != 0) {
                    [swself->_commentTableView.legendFooter endRefreshing];
                    [swself->_commentTableView.footer noticeNoMoreData];
                }
                else
                {
                    if (swself->_commentlistLoading) {
                        return;
                    }
                    
                    NSUInteger page = swself->_commentArray.count/kSizeNum + 1;
                    [swself commentListRequestWithItemid:[HSPublic controlNullString:swself.itemID] size:kSizeNum key:[HSPublic getIPAddress:YES] page:page loadMore:YES];
                }
            }
                break;
            case HSCommentImgType:
            {
                if (swself->_commentImgArray.count%kSizeNum != 0) {
                    [swself->_commentTableView.legendFooter endRefreshing];
                    [swself->_commentTableView.footer noticeNoMoreData];
                }
                else
                {
                    if (swself->_commentImgLoading) {
                        return;
                    }

                    NSUInteger page = swself->_commentImgArray.count/kSizeNum + 1;
                    [swself commentImgListRequestWithItemid:[HSPublic controlNullString:swself.itemID] size:kSizeNum key:[HSPublic getIPAddress:YES] page:page loadMore:YES];
                }
            }
                break;
        }

    }];
    
    _commentTableView.tableFooterView = [UIView new];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取评论的请求
- (void)commentListRequestWithItemid:(NSString *)cid size:(NSUInteger)size key:(NSString *)key page:(NSUInteger)page loadMore:(BOOL)loadMore
{
    [self showhudLoadingWithText:nil isDimBackground:YES];
    _commentlistLoading = YES;
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonItemid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                    kPostJsonSize:[NSNumber numberWithInteger:size],
                                    kPostJsonPage:[NSNumber numberWithInteger:page]};
    
    [self.httpRequestOperationManager POST:kGetCommentByItemIdURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"JSON:  %@",[HSPublic dictionaryToJson:parametersDic]);
        NSLog(@"%s\nresponse=%@",__func__,operation.responseString);
         _commentlistLoading = NO;
        [_commentTableView.legendFooter endRefreshing];
        [self hiddenHudLoading];
        
        if (_filterType != HSCommentTotalType) { // 加载更多的与当前filter不一样  返回
            return ;
        }

        if ((operation.responseData == nil) && ![NSJSONSerialization isValidJSONObject:operation.responseData]) {
            return ;
        }
        
        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && [json isKindOfClass:[NSDictionary class]]) {
            HSCommentListModel *listModel = [[HSCommentListModel alloc] initWithDictionary:json error:nil];
        
            if (loadMore) {
                if (_commentArray.count == 0) {
                    _commentArray = listModel.comment_list;
                }
                else
                {
                    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray:_commentArray];
                    [tmpArr addObjectsFromArray:listModel.comment_list];
                    _commentArray = tmpArr;
                }
            }
            else
            {
                _commentArray = listModel.comment_list;
            }
            
            [_commentTableView reloadSections:[[NSIndexSet alloc ] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }];
    
}

- (void)commentImgListRequestWithItemid:(NSString *)cid size:(NSUInteger)size key:(NSString *)key page:(NSUInteger)page loadMore:(BOOL)loadMore
{
    [self showhudLoadingWithText:nil isDimBackground:YES];
    _commentImgLoading = YES;
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonItemid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                    kPostJsonSize:[NSNumber numberWithInteger:size],
                                    kPostJsonPage:[NSNumber numberWithInteger:page]};
    
    [self.httpRequestOperationManager POST:kGetCommentHasImgByItemIdURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"JSON:  %@",[HSPublic dictionaryToJson:parametersDic]);
         NSLog(@"%s\nresponse=%@",__func__,operation.responseString);
        
        _commentImgLoading = NO;
        [_commentTableView.legendFooter endRefreshing];
        
        [self hiddenHudLoading];
        if (_filterType != HSCommentImgType) {
            return ;
        }
        
        if ((operation.responseData == nil) && ![NSJSONSerialization isValidJSONObject:operation.responseData]) {
            return ;
        }
        
        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&err];

        if (err == nil && [json isKindOfClass:[NSDictionary class]]) {
            HSCommentListModel *listModel = [[HSCommentListModel alloc] initWithDictionary:json error:nil];
            
            if (loadMore) {
                if (_commentImgArray.count == 0) {
                    _commentImgArray = listModel.comment_list;
                }
                else
                {
                    NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithArray:_commentImgArray];
                    [tmpArr addObjectsFromArray:listModel.comment_list];
                    _commentImgArray = tmpArr;
                }
            }
            else
            {
                _commentImgArray = listModel.comment_list;
            }

            [_commentTableView reloadSections:[[NSIndexSet alloc ] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
           
        }

    }];
    
}

- (void)commentInfoListRequestWithItemid:(NSString *)cid size:(NSUInteger)size key:(NSString *)key page:(NSUInteger)page
{
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonItemid:[NSNumber numberWithLongLong:[cid longLongValue]],
                                    kPostJsonSize:[NSNumber numberWithInteger:size],
                                    kPostJsonPage:[NSNumber numberWithInteger:page]};
    
    [self.httpRequestOperationManager POST:kGetCommentInfoURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"JSON:  %@",[HSPublic dictionaryToJson:parametersDic]);
        NSLog(@"%s\nresponse=%@",__func__,operation.responseString);
        [_commentTableView.header endRefreshing];
        
        if ((operation.responseData == nil) && ![NSJSONSerialization isValidJSONObject:operation.responseData]) {
            return ;
        }

        NSError *err = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && [json isKindOfClass:[NSDictionary class]]) {
            
            _infoModel  = [[HSCommentInfoModel alloc] initWithDictionary:json error:nil];
            [_commentTableView reloadSections:[[NSIndexSet alloc ] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
}

#pragma mark - 
- (void)openPhotoBrowser:(NSIndexPath *)indexPath
{
    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    
    // 数据源/delegate
    // 动画方式
    /*
     *
     UIViewAnimationAnimationStatusZoom = 0, // 放大缩小
     UIViewAnimationAnimationStatusFade , // 淡入淡出
     UIViewAnimationAnimationStatusRotate // 旋转
     pickerBrowser.status = UIViewAnimationAnimationStatusFade;
     */
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    //pickerBrowser.photos = _browsePhotoArray;
    // 是否可以删除照片
    pickerBrowser.editing = NO;
    // 当前分页的值
    // pickerBrowser.currentPage = indexPath.row;
    // 传入组
    pickerBrowser.currentIndexPath = indexPath;
    // 展示控制器
    [pickerBrowser showPickerVc:self];

}

#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return _browsePhotoArray.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    NSString *imageObj = _browsePhotoArray[indexPath.row];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@",kCommentImageHeaderURL,imageObj];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:fullPath];
    CGRect rect = [_photoTmpView convertRect:_photoTmpView.frame toView:self.view];
    NSLog(@"%@",NSStringFromCGRect(rect));
    UIImageView *imgView = [UIImageView new];
    imgView.frame = rect;
    photo.toView =  imgView;// _photoTmpView;
    return photo;
}


#pragma mark - tableview dataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 1;
    
    if (section == 2) {
        if (_filterType == HSCommentTotalType) {
            num = _commentArray.count;
        }
        else
        {
            num = _commentImgArray.count;
        }
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 顶部 包含评论信息的cell
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndentifierSection0 forIndexPath:indexPath];
        
        HSCommentInfoView *infoView = (HSCommentInfoView *)[cell.contentView viewWithTag:1021];
        
        if (infoView == nil) {
            infoView = [[HSCommentInfoView alloc] initWithFrame:CGRectZero];
            infoView.tag = 1021;
            infoView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:infoView];
            [cell.contentView HS_edgeFillWithSubView:infoView];
        }
        [infoView setUpWithInfoModel:_infoModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
    else if (indexPath.section == 2) // 详细评论
    {
        if (_filterType == HSCommentImgType) {
            
            HSCommentImgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommentImgTableViewCell class]) forIndexPath:indexPath];
            HSCommentItemModel *itemModel = _commentImgArray[indexPath.row];
            [cell setUpWithItemModel:itemModel];
            [cell addSubImgViewsWithList:itemModel.list];
            
            __weak typeof(self) weakSelf = self;
            cell.imgActionBlock = ^(NSUInteger idx, UIImageView *imgView){
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                if (strongSelf == nil) {
                    return ;
                }
                
                strongSelf->_browsePhotoArray = itemModel.list;
                strongSelf->_photoTmpView = imgView;
                NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:0];
                [strongSelf openPhotoBrowser:index];
            };
            
            return cell;

        }
        else
        {
            HSCommentItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommentItemTableViewCell class]) forIndexPath:indexPath];
            HSCommentItemModel *itemModel = _commentArray[indexPath.row];
            [cell setUpWithItemModel:itemModel];
            
            return cell;

        }
    }
    else
    {
        HSCommentFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommentFilterTableViewCell class]) forIndexPath:indexPath];
        
        __weak typeof(self) wself = self;
        
        switch (_filterType) {
            case HSCommentTotalType:
            {
                cell.totalCommentsBtn.selected = YES;
                cell.imgCommentsBtn.selected = NO;
            }
                break;
            case HSCommentImgType:
            {
                cell.totalCommentsBtn.selected = NO;
                cell.imgCommentsBtn.selected = YES;
            }
                break;
        }
        
        cell.filterBlock = ^(int idx){
            __strong typeof(wself) swself = wself;
            
            if (swself == nil) {
                return ;
            }
            
            [swself->_commentTableView.footer resetNoMoreData];
            
            switch (idx) {
                case 0: // 查看评论列表
                {
                    swself->_filterType = HSCommentTotalType;
                    [swself commentListRequestWithItemid:[HSPublic controlNullString:swself.itemID] size:kSizeNum key:[HSPublic getIPAddress:YES] page:1 loadMore:NO];
                }
                    break;
                case 1: // 查看带有图片的评论列表
                {
                    swself->_filterType = HSCommentImgType;
                    [self commentImgListRequestWithItemid:[HSPublic controlNullString:_itemID] size:kSizeNum key:[HSPublic getIPAddress:YES] page:1 loadMore:NO];
                }
                    break;
                    
                default:
                    break;
            }
            
            // 切换就刷新
            [swself->_commentTableView reloadSections:[[NSIndexSet alloc ] initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        
        return cell;
    }
    
}

// 去除左边分隔符15 像素
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat hei = 44;
    
    if (indexPath.section == 0) {
        hei = 120;
    }
    else if (indexPath.section == 2)
    {
        
        if (_filterType == HSCommentTotalType) {
            if (_holderItemCell == nil) {
                _holderItemCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCommentItemTableViewCell class])];
            }
            
            _holderItemCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(_holderItemCell.bounds));
            HSCommentItemModel *itemModel = _commentArray[indexPath.row];
            [_holderItemCell setUpWithItemModel:itemModel];
            
            [_holderItemCell setNeedsLayout];
            [_holderItemCell layoutIfNeeded];
            
            // Get the actual height required for the cell
            CGFloat height = [_holderItemCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            
            hei = height + 1;
            NSLog(@"hei=%f",height);

        }
        else
        {
            HSCommentItemModel *itemModel = _commentImgArray[indexPath.row];
            hei = [HSCommentImgTableViewCell cellHeightWithImgCount:itemModel.list.count cellWidth:CGRectGetWidth(_commentTableView.frame)];
        }
    }
    
    return hei;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
