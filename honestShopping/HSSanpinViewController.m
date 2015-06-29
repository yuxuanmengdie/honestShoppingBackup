//
//  HSSanpinViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-23.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSanpinViewController.h"
#import "HSCommodityCollectionViewCell.h"
#import "CHTCollectionViewWaterfallLayout.h"

#import "HSSanPinfitterView.h"
#import "UIView+HSLayout.h"
#import "UIImageView+WebCache.h"
#import "UIView+HSLayout.h"

#import "HSCommodtyItemModel.h"

@interface HSSanpinViewController ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
CHTCollectionViewDelegateWaterfallLayout>
{
    NSMutableDictionary *_sanpinDataDic;
    
    NSMutableDictionary *_typeLoadingDic;
    
    int _sanpintype;
    
    UICollectionView *_sanpinCollectionView2;
    
    UICollectionView *_sanpinCollectionView3;
    
    UICollectionView *_sanpinCollectionView4;
}

@property (weak, nonatomic) IBOutlet HSSanPinfitterView *fitterView;

@property (weak, nonatomic) IBOutlet UICollectionView *sanpinCollectionView;
@end

@implementation HSSanpinViewController

static NSString *const kCommodityCellIndentifier = @"CommodityCellIndentifier_iden";

static const int kCellImgViewTag = 500;

static const int kSanpinCollectionViewTagOri = 800;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sanpinDataDic = [[NSMutableDictionary alloc] init];
    _typeLoadingDic = [[NSMutableDictionary alloc] init];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    _sanpinCollectionView2 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    _sanpinCollectionView3 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    _sanpinCollectionView4 = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    [self initCollectionView:_sanpinCollectionView2];
    [self initCollectionView:_sanpinCollectionView3];
    [self initCollectionView:_sanpinCollectionView4];
    _sanpinCollectionView.tag = kSanpinCollectionViewTagOri;
    _sanpinCollectionView2.tag = kSanpinCollectionViewTagOri + 1;
    _sanpinCollectionView3.tag = kSanpinCollectionViewTagOri + 2;
    _sanpinCollectionView4.tag = kSanpinCollectionViewTagOri + 3;
    
    [_sanpinCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCommodityCellIndentifier];
    
    _sanpinCollectionView.showsVerticalScrollIndicator = YES;
    _sanpinCollectionView.delegate = self;
    _sanpinCollectionView.dataSource = self;
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 1;
    _sanpinCollectionView.collectionViewLayout = layout;
    
    [self fitterViewSetUp];

}

#pragma mark -
#pragma mark 初始化collectionView
- (void)initCollectionView:(UICollectionView *)sanpinView
{
    sanpinView.backgroundColor = [UIColor whiteColor];
    sanpinView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sanpinView];
    _fitterView.translatesAutoresizingMaskIntoConstraints = NO;
    id top = _fitterView;
    [self.view HS_dispacingWithFisrtView:top fistatt:NSLayoutAttributeBottom secondView:sanpinView secondAtt:NSLayoutAttributeTop constant:0];
    [self.view HS_dispacingWithFisrtView:self.view fistatt:NSLayoutAttributeLeading secondView:sanpinView secondAtt:NSLayoutAttributeLeading constant:0];
    [self.view HS_dispacingWithFisrtView:self.view fistatt:NSLayoutAttributeTrailing secondView:sanpinView secondAtt:NSLayoutAttributeTrailing constant:0];
    [self.view HS_dispacingWithFisrtView:self.view fistatt:NSLayoutAttributeBottom secondView:sanpinView secondAtt:NSLayoutAttributeBottom constant:0];
    
    [sanpinView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCommodityCellIndentifier];
    
    sanpinView.delegate = self;
    sanpinView.dataSource = self;
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.columnCount = 1;
    sanpinView.collectionViewLayout = layout;
}


- (void)showCollectionView:(int)idx
{
    _sanpinCollectionView.hidden = YES;
    _sanpinCollectionView2.hidden = YES;
    _sanpinCollectionView3.hidden = YES;
    _sanpinCollectionView4.hidden = YES;
    
   
    [self sanpinViewWithIdx:idx].hidden = NO;
}

- (UICollectionView *)sanpinViewWithIdx:(int)idx
{
    UICollectionView *collectionView = (UICollectionView *)[self.view viewWithTag:idx+kSanpinCollectionViewTagOri];
    return collectionView;
}

- (void)fitterViewSetUp
{
    _fitterView.translatesAutoresizingMaskIntoConstraints = NO;
    _fitterView.backgroundColor = [UIColor whiteColor];
    [_fitterView buttonWithTitles:@[@"有机\n产品",@"绿色\n产品",@"无公害\n产品",@"地理\n标志"]];
    __weak typeof(self) wself = self;
    _fitterView.actionBlock = ^(int idx){
        __strong typeof(wself) swself = wself;
        [swself showCollectionView:idx];
        int type = idx + 1;
        swself->_sanpintype = type;
        
        NSNumber *isLoading = _typeLoadingDic[[self p_keyFromType:type]];
        NSArray *typeArr = _sanpinDataDic[[self p_keyFromType:type]];
        if ((isLoading == nil || ![isLoading boolValue]) && typeArr.count == 0) {
            [swself sanpinTypeRequest:type key:[HSPublic md5Str:[HSPublic getIPAddress:YES]]];
        }
        [[swself sanpinViewWithIdx:idx] reloadData];
        
        
    };
    [_fitterView beginActionWithIdx:0];
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
#pragma mark 三品一标分类  获取三品一标(1.有机产品2.绿色产品3.无公害产品4.地理标志)
- (void)sanpinTypeRequest:(int)type key:(NSString *)key
{
    [_typeLoadingDic setObject:@YES forKey:[self p_keyFromType:type]];
    
    NSDictionary *parametersDic = @{kPostJsonKey:key,
                                    kPostJsonType:[NSNumber numberWithInt:type]
                                    };
    
    [self.httpRequestOperationManager POST:kGetSpybByTypeURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@/n %@", responseObject,[HSPublic dictionaryToJson:parametersDic]);
        [_typeLoadingDic setObject:@NO forKey:[self p_keyFromType:type]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response=%@",operation.responseString);
        [_typeLoadingDic setObject:@NO forKey:[self p_keyFromType:type]];
        NSString *str = (NSString *)operation.responseString;
        NSData *data =  [str dataUsingEncoding:NSUTF8StringEncoding];
        if (data == nil) {
            return ;
        }
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"!!!!%@",json);
        
        if ([json isKindOfClass:[NSArray class]] && jsonError == nil) {
            
            NSArray *jsonArr = (NSArray *)json;
            NSMutableArray *tmp = [[NSMutableArray alloc] init];
            [jsonArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    HSCommodtyItemModel *itemModel = [[HSCommodtyItemModel alloc] initWithDictionary:obj error:nil];
                    [tmp addObject:itemModel];
                }
            }];
            [_sanpinDataDic setObject:tmp forKey:[self p_keyFromType:type]];
            [[self  sanpinViewWithIdx:type-1] reloadData];
            
        }
        
    }];

}



#pragma  mark collectionView dataSource and delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   
    int tag = (int)collectionView.tag - kSanpinCollectionViewTagOri + 1; //sanpinType 从1开始
     NSArray *typeArr = _sanpinDataDic[[self p_keyFromType:tag]];
    
    return typeArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommodityCellIndentifier forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:kCellImgViewTag];
    if (imgView == nil) {
        imgView = [[UIImageView alloc] init];
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        imgView.tag = kCellImgViewTag;
        [cell addSubview:imgView];
        [cell HS_edgeFillWithSubView:imgView];
    }
    int tag = (int)collectionView.tag - kSanpinCollectionViewTagOri + 1; //sanpinType 从1开始
    NSArray *typeArr = _sanpinDataDic[[self p_keyFromType:tag]];
    HSCommodtyItemModel *itemModel = typeArr[indexPath.row];
    imgView.image = kPlaceholderImage;
    [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageHeaderURL,itemModel.imageurl]] placeholderImage:kPlaceholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            // do something with image
        
            NSValue *imgSize =  [NSValue valueWithCGSize:image.size];
            NSDictionary *dic = [self.imageSizeDic objectForKey:[self p_keyFromIndex:indexPath selectedIdx:tag]];
            if (dic != nil ) {
                NSURL *imgURL = dic[kImageURLKey];
                NSValue *sizeValue = dic[kImageSizeKey];
                if ([imgURL isEqual:imageURL] && [sizeValue isEqual:imgSize]) {
                    return ;
                }
            }
            
            NSDictionary *tmpDic = @{kImageSizeKey:imgSize,
                                     kImageURLKey:imageURL};
            
            [self.imageSizeDic setObject:tmpDic forKey:[self p_keyFromIndex:indexPath selectedIdx:tag]];
            if (collectionView.dataSource != nil ) {
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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize imgSize = CGSizeMake(80, 40);
    int tag = (int)collectionView.tag - kSanpinCollectionViewTagOri + 1; //sanpinType 从1开始
    NSDictionary *dic = [self.imageSizeDic objectForKey:[self p_keyFromIndex:indexPath selectedIdx:tag]];
    if (dic != nil) {
        NSValue *sizeValue = dic[kImageSizeKey];
        imgSize = [sizeValue CGSizeValue];
    }

    return imgSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = (int)collectionView.tag - kSanpinCollectionViewTagOri + 1; //sanpinType 从1开始
    NSArray *typeArr = _sanpinDataDic[[self p_keyFromType:tag]];
    HSCommodtyItemModel *itemModel = typeArr[indexPath.row];
    
    if (collectionView == _sanpinCollectionView) {
        _sanpinCategoryType = 1;
    }
    else if (collectionView == _sanpinCollectionView2)
    {
        _sanpinCategoryType = 2;
    }
    else if (collectionView == _sanpinCollectionView3)
    {
        _sanpinCategoryType = 3;
    }
    else if (collectionView == _sanpinCollectionView4)
    {
        _sanpinCategoryType = 4;
    }
    
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(itemModel);
    }
}

#pragma mark -
#pragma mark 根据选择的按钮顺序和index
- (NSString *)p_keyFromIndex:(NSIndexPath *)index selectedIdx:(int)idx
{
    NSString *str = [self keyFromIndex:index];
    NSString *result = [NSString stringWithFormat:@"%@_idx%d",str,idx];
    
    return result;
}

#pragma mark -
#pragma mark 根据type 返回key
- (NSString *)p_keyFromType:(int)type
{
    NSString *str = [NSString stringWithFormat:@"key%d",type];
    return str;
}

@end
