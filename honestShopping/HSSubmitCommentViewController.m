//
//  HSSubmitCommentViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-9-22.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSSubmitCommentViewController.h"

#import "HSSubmitCommentOrderInfoTableViewCell.h"
#import "HSSubmitCommentStarTableViewCell.h"
#import "HSSubmitCommentTableViewCell.h"
#import "HSSubmitOrderCommdityTableViewCell.h"
#import "HSOrderModel.h"
#import "ZLPhoto.h"
#import "UIImageView+WebCache.h"

@interface HSSubmitCommentViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate>
{
    
    HSOrderModel *_orderModel;
    
    NSString *_commentStr;
    
    // 记录star
    float _starValue;
}
@property (nonatomic , strong) NSMutableArray *assets;

@property (nonatomic, strong) UITableView *submitTableView;

@end

@implementation HSSubmitCommentViewController

static const NSInteger kExtraCellCount = 3;

static NSString *const kPhotpHolderImg = @"icon_camera";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _starValue = 5;
    
    [self.submitTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitCommentOrderInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitCommentOrderInfoTableViewCell class])];
    [self.submitTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitCommentStarTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitCommentStarTableViewCell class])];
    [self.submitTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitCommentTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitCommentTableViewCell class])];
    [self.submitTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class])];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - subViews commitInit
- (UITableView *)submitTableView
{
    if (_submitTableView == nil) {
        
        _submitTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _submitTableView.backgroundColor = ColorRGB(244, 244, 244);
        [self.view addSubview:_submitTableView];
        _submitTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _submitTableView.dataSource = self;
        _submitTableView.delegate = self;
        _submitTableView.tableFooterView = [UIView new];
        
        if ([_submitTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_submitTableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_submitTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_submitTableView setLayoutMargins:UIEdgeInsetsZero];
        }

        id top = self.topLayoutGuide;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top][_submitTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(top,_submitTableView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_submitTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_submitTableView)]];
        
    }
    
    return _submitTableView;
}

//- (NSMutableArray *)assets
//{
//    if (_assets == nil) {
//        _assets = [[NSMutableArray alloc] initWithCapacity:1];
//    }
//    
//    return _assets;
//}

#pragma mark - 选择照片
- (void)selectPhotos {
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"打开照相机",@"从手机相册获取",nil];
    
    [myActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self openCamera];
            break;
        case 1:  //打开本地相册
            [self openLocalPhoto];
            break;
    }
}

- (void)openCamera{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    cameraVc.maxCount = 1;
    __weak typeof(self) WeakSelf = self;
    cameraVc.callback = ^(NSArray *cameras){
        __strong typeof(WeakSelf) StrongSelf = WeakSelf;
        
        if (StrongSelf == nil) {
            return ;
        }

        WeakSelf.assets = [NSMutableArray arrayWithArray:cameras];
        [StrongSelf.submitTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:StrongSelf->_dataArray.count + kExtraCellCount - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    [cameraVc showPickerVc:self];
}

- (void)openLocalPhoto{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.maxCount = 1;
    // 最多能选9张图片
    pickerVc.status = PickerViewShowStatusCameraRoll;
    [pickerVc showPickerVc:self];
    
    __weak typeof(self) WeakSelf = self;
    pickerVc.callBack = ^(NSArray *assets){
        
        __strong typeof(WeakSelf) StrongSelf = WeakSelf;
        
        if (StrongSelf == nil) {
            return ;
        }

        WeakSelf.assets = [NSMutableArray arrayWithArray:assets];
        [StrongSelf.submitTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:StrongSelf->_dataArray.count + kExtraCellCount - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
}

#pragma mark - ##网络请求##
#pragma mark - 获取订单详情
- (void)getOrderDetailRequest:(NSString *)uid orderID:(NSString *)orderID sessionCode:(NSString *)sessionCode
{
    [self showNetLoadingView];
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonOrderId:orderID,
                                    kPostJsonSessionCode:sessionCode
                                    };
    // 142346261  123456
    
    [self.httpRequestOperationManager POST:kGetOrderDetailURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} success:^(AFHTTPRequestOperation *operation, id responseObject) { /// 失败
        NSLog(@"success\n%@",operation.responseString);
        
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
        
        if ([HSPublic isErrorCode:json error:jsonError]) { /// 有错误码
            NSString *errorMsg = [HSPublic errorMsgWithJson:json error:jsonError];
            if (errorMsg.length > 0) {
                [self showHudWithText:errorMsg];
            }
            return;
        }
        
        if (jsonError == nil && [json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tmpDic = (NSDictionary *)json;
            HSOrderModel *orderModel = [[HSOrderModel alloc] initWithDictionary:tmpDic error:nil];
            if (orderModel.id.length > 0) {
                _orderModel = orderModel;
                _dataArray = _orderModel.item_list;
                
                [_submitTableView reloadData];
            }
        }
        else
        {
            
        }
    }];
    
}

- (void)AddCommentRequestWithUid:(NSString *)uid itemID:(NSString *)itemID phone:(NSString *)phone star:(float)star comment:(NSString *)comment sessionCode:(NSString *)sessionCode
{
    [self showhudLoadingInWindowWithText:@"提交中..." isDimBackground:YES];
    
    NSDictionary *parametersDic = @{kPostJsonKey:[HSPublic md5Str:[HSPublic getIPAddress:YES]],
                                    kPostJsonUid:uid,
                                    kPostJsonItemid:itemID,
                                    kPostJsonPhone:phone,
                                    kPostJsonStar:[NSNumber numberWithFloat:star],
                                    kPostJsonComment:comment,
                                    kPostJsonSessionCode:sessionCode
                                    };
    NSString *tmp = [NSTemporaryDirectory() stringByAppendingString:@"1.jpg"];
    NSURL *filePath = [NSURL fileURLWithPath:tmp];
    
    BOOL isFileUpload = NO;
    if (self.assets.count > 0) {
        isFileUpload = YES;
        
        UIImage *img = [self p_selectedPhotoWithCompressionImage:YES];
        NSData *data = UIImageJPEGRepresentation(img, 0.01);
        [data writeToFile:tmp atomically:YES];
    }
    
    [self.httpRequestOperationManager POST:kAddCommentURL parameters:@{kJsonArray:[HSPublic dictionaryToJson:parametersDic]} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (isFileUpload) {
            
            NSError *error = nil;
            
            NSData *img = [NSData dataWithContentsOfURL:filePath];
            
            BOOL suc = [formData appendPartWithFileURL:filePath name:@"imgs[]" error:&error];
            
            NSLog(@"img = %@;suc=%d, error=%@",img,suc,error.description);
        }
       
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success\n%@",operation.responseString);
        
        [self hiddenHudLoading];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"failed!!");
        [self hiddenHudLoading];
        if (operation.responseData == nil) {
            [self showHudWithText:@"评论失败"];
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
            
            NSString *str = @"评论成功";
            if (isSuccess) {
                
                
            }
            else
            {
                str = @"评论失败";
                
            }
            
            [self backAction:nil];
            [self showHudInWindowWithText:str];
            
        }
        else
        {
            [self showHudWithText:@"评论失败"];
        }

    }];
    
}


#pragma mark - tableview dataSource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count + kExtraCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //  订单信息
        HSSubmitCommentOrderInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitCommentOrderInfoTableViewCell class]) forIndexPath:indexPath];
        cell.orderNOLabel.text = [NSString stringWithFormat:@"订单：%@",[HSPublic controlNullString:_orderModel.orderId]];
        cell.timeLabel.text = [HSPublic controlNullString:[HSPublic dateFormWithTimeDou:[_orderModel.add_time doubleValue]]];
        
        return cell;
        
    }
    else if (indexPath.row == (_dataArray.count + kExtraCellCount - 1))// 提交评论
    {
        HSSubmitCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitCommentTableViewCell class]) forIndexPath:indexPath];
        // 判断类型来获取Image
        if (self.assets.count == 0) {
            cell.photoImgView.image = [UIImage imageNamed:kPhotpHolderImg];
        }
        else
        {
            ZLPhotoAssets *asset = self.assets[0];
            if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
                 cell.photoImgView.image = asset.thumbImage;
            }else if ([asset isKindOfClass:[NSString class]]){
                [cell.photoImgView sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:kPhotpHolderImg]];
            }else if([asset isKindOfClass:[UIImage class]]){
                cell.photoImgView.image = (UIImage *)asset;
            }else if ([asset isKindOfClass:[ZLCamera class]]){
                cell.photoImgView.image = [asset thumbImage];
            }

        }
        cell.textView.text = _commentStr;

        __weak typeof(self) WeakSelf = self;
        
        cell.callBackBlock = ^(int idx){ // 0 打开photo  1 提交
            
            __strong typeof(WeakSelf) StrongSelf = WeakSelf;
            
            if (StrongSelf == nil) {
                return ;
            }
            
            if (0 == idx) {
                [StrongSelf selectPhotos];
            }
            else if (1 == idx)
            {
                if (StrongSelf->_commentStr.length == 0) {
                    
                    [StrongSelf showHudWithText:@"评论内容不能为空"];
                    
                    return;
                }
                
                HSOrderitemModel *itemModel = StrongSelf.dataArray[0];
                
                NSString *phone = @"";
                if ([HSPublic loginType] != kAccountLoginType) { // 第三方登录
                    phone = [HSPublic lastOtherUserName] ;
                }
                else
                {
                    phone = [HSPublic controlNullString:_userInfoModel.phone];
                }

                [StrongSelf AddCommentRequestWithUid:[HSPublic controlNullString:StrongSelf.userInfoModel.id] itemID:[HSPublic controlNullString:itemModel.itemId] phone:phone star:StrongSelf->_starValue comment:[HSPublic controlNullString:StrongSelf->_commentStr] sessionCode:[HSPublic controlNullString:StrongSelf.userInfoModel.sessionCode]];

            }
        };
        
        cell.textChangedBlock = ^(NSString *text){
            
            __strong typeof(WeakSelf) StrongSelf = WeakSelf;
            
            if (StrongSelf == nil) {
                return ;
            }
            
            StrongSelf->_commentStr = text;
            NSLog(@"text=%@",text);

        };
        
        return cell;
    }
    else if (indexPath.row == (_dataArray.count + kExtraCellCount - 2))// star
    {
        HSSubmitCommentStarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitCommentStarTableViewCell class]) forIndexPath:indexPath];
        cell.starRatingView.value = _starValue;
        
         __weak typeof(self) WeakSelf = self;
        cell.changedBlcok = ^(float value){
            __strong typeof(WeakSelf) StrongSelf = WeakSelf;
            
            if (StrongSelf == nil) {
                return ;
            }

            NSLog(@"star=%f",value);
            StrongSelf->_starValue = value;
        };
        
               
        return cell;
    }
    else // 商品
    {
        HSSubmitOrderCommdityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSSubmitOrderCommdityTableViewCell class]) forIndexPath:indexPath];
        // 因为cell的起始位置index.row = 1 所以减去1
        HSOrderitemModel *itemlModel = _dataArray[indexPath.row-1];
        [cell setupWithOrderItemModel:itemlModel];

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
    
    if (indexPath.row == (_dataArray.count + kExtraCellCount - 1)) {
     
        hei = 168;
    }
    else if (indexPath.row == (_dataArray.count + kExtraCellCount - 2))
    {
        hei = 44;
    }
    else if (indexPath.row == 0)
    {
        hei = 30;
    }
    else
    {
        hei = 80;
    }
    return hei;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - private method
- (UIImage *)p_selectedPhotoWithCompressionImage:(BOOL)isOri
{
    if (self.assets.count == 0) {
        return nil;
    }
    
    UIImage *img = nil;
    
    ZLPhotoAssets *asset = self.assets[0];
    if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
        
        if (isOri)
        {
            img = asset.compressionImage;
        }
        else
        {
            img = asset.thumbImage;
        }
    } else if([asset isKindOfClass:[UIImage class]]){
        img = (UIImage *)asset;
    }else if ([asset isKindOfClass:[ZLCamera class]]){
        ZLCamera *camera = (ZLCamera *)asset;
        if (isOri)
        {
            img = camera.photoImage;
        }
        else
        {
            img = camera.thumbImage;
        }

    }
    
    return img;
}

@end
