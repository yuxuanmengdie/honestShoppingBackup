//
//  HSBaseViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-4-27.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSBaseViewController.h"
#import "UIView+HSLayout.h"
#import "HSRotateAnimationView.h"
#import "MBProgressHUD.h"


@interface HSBaseViewController ()
{
     //AFHTTPRequestOperationManager *_httpRequestOperationManager;
    
     UIControl *_showMsgView;
    
    MBProgressHUD *_loadingHud;
}

@end

@implementation HSBaseViewController
@synthesize httpRequestOperationManager = _httpRequestOperationManager;

/// 重新加载 的label tag
static const int kShowMsgLabelTag = 5000;
/// 请求失败的图片 tag
static const int kShowMsgImgViewTag = 5001;
/// 加载中的动画视图 tag
static const int kShowMsgLoadingTag = 5002;
/// placeView 的tag
static const int kPlaceViewTag = 5003;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initOperationManager];
    [self addBackButton];
    
    _isRequestLoading = NO;
    self.imageSizeDic = [[NSMutableDictionary alloc] init];
    
    self.navigationController.navigationBar.translucent = NO;
    
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
#pragma mark 定义rightItem
- (void)setNavBarRightBarWithTitle:(NSString *)rightTitle action:(SEL)seletor
{
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStylePlain target:self action:seletor];
   
}

#pragma mark -
#pragma mark 初始化请求列表

- (void)initOperationManager
{
    _httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc] init];
    _httpRequestOperationManager.requestSerializer.timeoutInterval = 15;
}


#pragma mark -
- (void)setUpShowMsgView
{
    [self hiddenMsg];
    
    _showMsgView = [[UIControl alloc] initWithFrame:CGRectZero];
    _showMsgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_showMsgView];
    [self.view HS_edgeFillWithSubView:_showMsgView];
    [_showMsgView addTarget:self action:@selector(reloadRequestData) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = kShowMsgLabelTag;
    label.font = [UIFont systemFontOfSize:14];
    [_showMsgView addSubview:label];
    label.text = @"点击重新加载";
    label.textColor = UIColorFromRGB(0x999999);
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [_showMsgView HS_centerXYWithSubView:label];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.tag = kShowMsgImgViewTag;
    imgView.image = [UIImage imageNamed:@"list_network_error"];
    [_showMsgView addSubview:imgView];
    [_showMsgView HS_dispacingWithFisrtView:label fistatt:NSLayoutAttributeTop secondView:imgView secondAtt:NSLayoutAttributeBottom constant:20];
    [_showMsgView HS_centerXWithSubView:imgView];
    
    HSRotateAnimationView *rotateView = [[HSRotateAnimationView alloc] initWithFrame:CGRectZero];
    rotateView.image = [UIImage imageNamed:@"icon_activity"];
    rotateView.tag = kShowMsgLoadingTag;
    [_showMsgView addSubview:rotateView];
    [_showMsgView HS_centerXYWithSubView:rotateView];
    
    
    [self.view bringSubviewToFront:_showMsgView];

}


- (void)rotateViewHidden
{
    HSRotateAnimationView *ratateView = (HSRotateAnimationView *)[_showMsgView viewWithTag:kShowMsgLoadingTag];
    [ratateView stopRotating];
    ratateView.hidden = YES;
}

- (void)showReqeustFailedMsg
{
    [self setUpShowMsgView];
    [self rotateViewHidden];
}


- (void)showReqeustFailedMsgWithText:(NSString *)text
{
    [self showReqeustFailedMsg];
    UILabel *label = (UILabel *)[_showMsgView viewWithTag:kShowMsgLabelTag];
    label.text = text;
}

#pragma mark - 
#pragma mark 显示加载视图
- (void)showNetLoadingView
{
    [self setUpShowMsgView];
    [_showMsgView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = YES;
    }];
    _showMsgView.userInteractionEnabled = NO;
    
    HSRotateAnimationView *ratateView = (HSRotateAnimationView *)[_showMsgView viewWithTag:kShowMsgLoadingTag];
    ratateView.hidden = NO;
    [ratateView startRotating];
    
    _isRequestLoading = YES;
}


- (void)hiddenMsg
{
    [_showMsgView removeFromSuperview];
    _showMsgView = nil;
    
    _isRequestLoading = NO;
}

#pragma mark -
#pragma mark hud 显示
- (void)showHudWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.alpha = 0.9;
    hud.labelText = text;
    //hud.margin = 10.f;
    hud.yOffset = 150;
    hud.animationType = MBProgressHUDAnimationZoomOut;// | MBProgressHUDAnimationZoomIn;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}


- (void)showhudLoadingWithText:(NSString *)text isDimBackground:(BOOL)isDim
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _loadingHud = hud;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = isDim;
    hud.alpha = 0.9;
    hud.labelText = text;
   // hud.margin = 5.f;
    //hud.animationType = MBProgressHUDAnimationZoomOut;// | MBProgressHUDAnimationZoomIn;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
}

- (void)showhudLoadingInWindowWithText:(NSString *)text isDimBackground:(BOOL)isDim
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _loadingHud = hud;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = isDim;
    hud.alpha = 0.8;
    hud.labelText = text;
   // hud.margin = 5.f;
    //hud.animationType = MBProgressHUDAnimationZoomOut;// | MBProgressHUDAnimationZoomIn;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
}


- (void)showHudInWindowWithText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.dimBackground = NO;
    hud.alpha = 0.9;
    hud.labelText = text;
    //hud.margin = 10.f;
    hud.yOffset = 150;
    hud.animationType = MBProgressHUDAnimationZoomOut;// | MBProgressHUDAnimationZoomIn;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}


- (void)hiddenHudLoading
{
    [_loadingHud hide:YES];
}

#pragma mark -
#pragma mark push VC
- (void)pushViewControllerWithIdentifer:(NSString *)identifier
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [stroyBoard instantiateViewControllerWithIdentifier:identifier];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark 添加返回按钮

- (void)addBackButton
{
    NSInteger count = [self.navigationController.viewControllers count];
    if (count >= 2)
    {
        //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];

        [self hiddenTabBar:YES];
    }

}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
     UIViewController *main = self.navigationController.parentViewController;
    if ([main isKindOfClass:[UITabBarController class]] && [self.navigationController.viewControllers count] < 2) {
        UIView *tabView = [main.view viewWithTag:kTabBarViewTag];
        UITabBarController *tabVC = (UITabBarController *)main;
        tabVC.tabBar.hidden = YES;
//        [tabVC.view bringSubviewToFront:tabView];
        tabView.hidden = NO;
//        [tabVC.view insertSubview:tabView aboveSubview:tabVC.tabBar];
    
    }

}

- (void)hiddenTabBar:(BOOL)isHidd
{
    NSInteger count = [self.navigationController.viewControllers count];
    if (count >= 2)
    {
        UIViewController *main = self.navigationController.parentViewController;
        
        if ([main isKindOfClass:[UITabBarController class]]) {
            UIView *tabView = [main.view viewWithTag:kTabBarViewTag];
            tabView.hidden = isHidd;
        }
    }

}

/// pop到顶层的navigation
- (void)popToRootNav
{
    
    
    NSLog(@"nav=%@,par = %@",self.navigationController,self.parentViewController);
    
    UIViewController *main = self.navigationController.parentViewController;
    UINavigationController *nav = self.navigationController;
    [self.navigationController popToRootViewControllerAnimated:YES];
    if ([main isKindOfClass:[UITabBarController class]] && [nav.viewControllers count] < 2) {
        UIView *tabView = [main.view viewWithTag:kTabBarViewTag];
        UITabBarController *tabVC = (UITabBarController *)main;
        tabVC.tabBar.hidden = YES;
        tabView.hidden = NO;        
    }

    
}

#pragma mark -
#pragma mark 占位view
- (void)placeViewWithImgName:(NSString *)imgName text:(NSString *)text
{
    [self removePlaceView];
    
    UIView *placeView = [[UIView alloc] init];
    placeView.backgroundColor = [UIColor whiteColor];
    placeView.translatesAutoresizingMaskIntoConstraints = NO;
    placeView.tag = kPlaceViewTag;
    [self.view addSubview:placeView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [placeView addSubview:imgView];
    
    UILabel *lbl = [[UILabel alloc] init];
    lbl.textColor = [UIColor grayColor];
    lbl.backgroundColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont systemFontOfSize:14];
    lbl.text = text;
    [placeView addSubview:lbl];
    lbl.translatesAutoresizingMaskIntoConstraints = NO;

    
    NSString *vfl1 = @"V:|[imgView]-8-[lbl]|";
    NSString *vfl2 = @"H:|-(>=0)-[imgView]";
    NSString *vfl3 = @"H:|-(>=0)-[lbl]|";
    NSString *vfl4 = @"H:|-(0@250)-[imgView]";
    NSString *vfl5 = @"H:|-(0@250)-[lbl]";
    NSDictionary *dic = NSDictionaryOfVariableBindings(imgView,lbl);
    NSArray *arr1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
    NSArray *arr2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
    NSArray *arr3 = [NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:dic];
    NSArray *arr4 = [NSLayoutConstraint constraintsWithVisualFormat:vfl4 options:0 metrics:nil views:dic];
    NSArray *arr5 = [NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:nil views:dic];
    [placeView addConstraints:arr1];
    [placeView addConstraints:arr2];
    [placeView addConstraints:arr3];
    [placeView addConstraints:arr4];
    [placeView addConstraints:arr5];
    [placeView HS_centerXWithSubView:imgView];
    [placeView HS_centerXWithSubView:lbl];
    [self.view HS_centerXYWithSubView:placeView];
    [self.view bringSubviewToFront:placeView];
}

- (void)removePlaceView
{
    UIView *placeView = [self.view viewWithTag:kPlaceViewTag];
    [placeView removeFromSuperview];
    placeView = nil;
}


#pragma mark -
#pragma mark tableView 处理介绍图片的url
- (NSString *)commodityIntroImgFullUrl:(NSString *)oriUrl
{
    if (oriUrl.length < 1) {
        return nil;
    }
    
    NSString *result = [NSString stringWithFormat:@"%@%@",kImageHeaderURL,oriUrl];
    return result;
}


- (NSString *)keyFromIndex:(NSIndexPath *)index
{
    if (index == nil) {
        return @"";
    }
    
    NSString *result = [NSString stringWithFormat:@"indexsec%ldrow%ld",(long)index.section,(long)index.row];
    return result;
}

#pragma mark -
#pragma mark 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark -
#pragma mark 点击重新加载
- (void)reloadRequestData
{
 //   [self hiddenMsg];
}

- (void)dealloc
{
    [_httpRequestOperationManager.operationQueue cancelAllOperations];
}
@end
